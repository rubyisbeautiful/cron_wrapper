require 'fileutils'
require 'timeout'

root  = File.expand_path(File.join(File.dirname(__FILE__), '..'))
cmd   = File.join root, 'bin/cron_wrapper'

def remove_lock
  FileUtils.rm_f "tmp/locks/awesome_script.lock" rescue nil
end

def remove_log
  FileUtils.rm_f "log/awesome_script.log" rescue nil
end


describe "cron_wrapper" do
  
  before(:all) do
    FileUtils.mkdir_p "#{root}/tmp/locks"
    FileUtils.mkdir_p "#{root}/log"
    FileUtils.mkdir_p "#{root}/lib/cron"
    File.open("#{root}/lib/cron/awesome_script.rb", 'w') do |file|
      file. << 'sleep(2); puts "awesome"'
    end
  end
    
  before(:each) do
    @pid = nil
    remove_log
  end
  
  describe "rails" do
    
    before(:all) do
      FileUtils.mkdir_p "config"
      
      File.open("#{root}/config/environment.rb", 'w') do |file|
        file << "class Rails; def self.root; return '#{root}'; end; end;"
      end
      
      File.open("#{root}/lib/cron/rails_script.rb", 'w') do |file|
        file << "str = Rails.root rescue 'no';  File.open('#{root}/tmp/result', 'w'){ |file| file << str }"
      end
    end
    
    after(:each) do
      FileUtils.rm_rf("tmp/result") rescue nil
    end
    
    after(:all) do
      FileUtils.rm_rf("#{root}/lib/cron/rails_script.rb")
      FileUtils.rm_rf("#{root}/config/environment.rb")
    end
    
    
    it "should not load rails if not passed on the commandline" do
      t = Thread.new { `#{cmd} --wrap rails_script --wrap-verbose --wrap-root #{root} --wrap-log log/rails_script.log` }
      t.join
      File.read(File.join(File.dirname(__FILE__), "..", "tmp/result")).should == "no"
    end
    
    it "should load rails if passed on the commandline" do
      t = Thread.new { `#{cmd} --wrap-rails --wrap rails_script --wrap-verbose --wrap-root #{root} --wrap-log log/rails_script.log` }
      t.join
      File.read("tmp/result").should == root
    end
  end
  
  
  
  describe "with optparse" do
    
    before(:all) do
      File.open("#{root}/lib/cron/uses_optparse.rb", 'w') do |file|
        file << 'File.open("tmp/result", "w") { |file| file << ARGV.join(", ") }'
      end
    end
    
    after(:each) do
      FileUtils.rm_rf("tmp/result") rescue nil
    end
    
    after(:all) do
      FileUtils.rm_rf("#{root}/lib/cron/uses_optparse.rb")
    end
    
    it "should pass options after -- to the subcommand" do
      t = Thread.new { `#{cmd} --wrap uses_optparse --wrap-verbose --wrap-root #{root} --wrap-log log/uses_optparse.log -- --foo bar` }
      t.join
      File.read("tmp/result").should == "--foo, bar"
    end
  end
  
  
  
  describe "logging" do
    it "should create log/awesome_script.log when passed on the commandline" do
      t = Thread.new { `#{cmd} --wrap awesome_script --wrap-verbose --wrap-root #{root} --wrap-log log/awesome_script.log` }
      t.join
      puts "#{Dir.entries(File.join(root,'log')).join(',')}"
      File.exists?("#{root}/log/awesome_script.log").should == true
    end
  end
  
  
  
  describe "locking" do
    
    before(:all) do
      FileUtils.mkdir_p "#{root}/tmp/locks"
      FileUtils.mkdir_p "#{root}/log"
      FileUtils.mkdir_p "#{root}/lib/cron"
      File.open("#{root}/lib/cron/awesome_script.rb", 'w') do |file|
        file. << 'sleep(2); puts "awesome"'
      end
    end
      
    before(:each) do
      @pid = nil
      remove_lock
    end


    it "should create the lock file in lock_dir using the --wrap-name if provided" do
      t = Thread.new { `#{cmd} --wrap awesome_script --wrap-name foobar_script --wrap-verbose --wrap-root #{root} --wrap-log log/awesome_script.log` }
      Timeout::timeout(3) do
        begin
          @pid = File.read "#{root}/tmp/locks/foobar_script.lock"
        rescue
          retry
        end
      end.should_not raise_error TimeoutError

      @pid.nil?.should_not == true
      t.join
    end

    
    it "should create a lock file in lock_dir if no lock file exists" do
      t = Thread.new { `#{cmd} --wrap awesome_script --wrap-verbose --wrap-root #{root} --wrap-log log/awesome_script.log` }
      Timeout::timeout(3) do
        begin
          @pid = File.read "#{root}/tmp/locks/awesome_script.lock"
        rescue
          retry
        end
      end.should_not raise_error TimeoutError
      
      @pid.nil?.should_not == true
      t.join
    end
    
    
    it "should remove the lock file in lock_dir after execution" do
      `#{cmd} --wrap awesome_script --wrap-root #{root} --wrap-log log/awesome_script.log`
      File.exists?("tmp/locks/awesome_script.lock").should == false
    end
    
    
    it "should have the pid of the currently executing thread in the lock file" do
      read_pid = nil
      @pid = Process.fork { `#{cmd} --wrap awesome_script --wrap-verbose --wrap-root #{root} --wrap-log log/awesome_script.log` }
      
      begin
        read_pid = File.read "#{root}/tmp/locks/awesome_script.lock"
      rescue
        retry
      end
      
      Process.wait
      @pid.nil?.should == false
      read_pid.nil?.should == false
      read_pid.should_not == ''
      read_pid.should == (@pid + 1).to_s
    end
    
    
    it "should not execute if the default lock file is there and the pid is valid" do
      File.open("#{root}/tmp/locks/awesome_script.lock", 'w') do |file|
        file << Process::pid
      end
      
      start_time  = Time.now
      Process.fork { `#{cmd} --wrap awesome_script --wrap-verbose --wrap-root #{root} --wrap-log log/awesome_script.log` }
      Process.wait
      end_time    = Time.now
      
      ((end_time - start_time) < 1).should == true
    end
    
    
    it "should execute if the default lock file is there but the pid is invalid" do
      File.open("#{root}/tmp/locks/awesome_script.lock", 'w') do |file|
        file << 'foo'
      end
      
      start_time  = Time.now
      Process.fork { `#{cmd} --wrap awesome_script --wrap-verbose --wrap-root #{root} --wrap-log log/awesome_script.log` }
      Process.wait
      end_time    = Time.now
      
      ((end_time - start_time) > 2).should == true
    end


    it "should execute if the lock file is there under a different name" do
      File.open("#{root}/tmp/locks/awesome_script.lock", 'w') do |file|
        file << Process::pid
      end

      start_time  = Time.now
      Process.fork { `#{cmd} --wrap awesome_script --wrap-name foobar_script --wrap-verbose --wrap-root #{root} --wrap-log log/awesome_script.log` }
      Process.wait
      end_time    = Time.now

      ((end_time - start_time) > 2).should == true
    end


    it "should not execute if the custom lock file is there and the pid is valid" do
      File.open("#{root}/tmp/locks/foobar_script.lock", 'w') do |file|
        file << Process::pid
      end

      start_time  = Time.now
      Process.fork { `#{cmd} --wrap awesome_script --wrap-name foobar_script --wrap-verbose --wrap-root #{root} --wrap-log log/awesome_script.log` }
      Process.wait
      end_time    = Time.now

      ((end_time - start_time) < 1).should == true
    end


    it "should execute if the custom lock file is there but the pid is invalid" do
      File.open("#{root}/tmp/locks/foobar_script.lock", 'w') do |file|
        file << 'foo'
      end

      start_time  = Time.now
      Process.fork { `#{cmd} --wrap awesome_script --wrap-name foobar_script --wrap-verbose --wrap-root #{root} --wrap-log log/awesome_script.log` }
      Process.wait
      end_time    = Time.now

      ((end_time - start_time) > 2).should == true
    end

  end
  
  
  
end
