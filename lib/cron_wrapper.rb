require 'optparse'
require 'logger'
require 'fileutils'
require 'pp'
class CronWrapper
  
  attr_reader :logger
  attr_reader :others
  
  def initialize(*args)
    @options = {}
    @options[:rails] = false
    @options[:root]       = '.'
    @options[:lock_dir]   = nil
    @options[:dry_run]    = false
    @options[:silent]     = false
    @options[:verbose]    = false
    @options[:log]        = nil
    @options[:target]     = nil
    @options[:extra]      = nil
    
    @others = []
    
    # do options
    foo = OptionParser.new do |opts|
      opts.banner = "Usage: cron_wrapper [options] 
        where script is the name (without file extension) of a file located by default in <root>/lib/cron
        Example: 
        > pwd 
        /home/projects/foo
        > ls lib/cron
        awesome_script.rb
        >cron_wrapper awesome_script
      "
      
      opts.on("--wrap FILE", "file to run") { |o| @options[:target] = o }
      opts.on("--wrap-dry-run", "dry run (default: off)") { |o| @options[:dry_run] = o }
      opts.on("--wrap-rails", "Try to load Rails (default: off)") { |o| @options[:rails] = o }
      opts.on("--wrap-root DIR", "Root or working directory (default: .)") { |o| @options[:root] = o }
      opts.on("--wrap-lock_dir DIR", "Lock dir (default: <root>/tmp/locks)") { |o| @options[:lock_dir] = o }
      opts.on("--wrap-log FILE", "log file relative to root (default: STDOUT)") { |o| @options[:log] = o }
      opts.on("--wrap-silent", "Do not output anything (default: off)") { |o| @options[:silent] = o }
      opts.on("--[no-]wrap-verbose", "Run verbosely (default: off)") { |o| @options[:verbose] = o }
      
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end
    
    @others = foo.order!
    
    # if they did not enter a script name, then give them usage
    if @options[:target].nil? or @options[:target] == ''
      puts foo.banner
      exit
    end
    
    
    # Setup rails
    if @options[:rails]
      libs = [ File.join(@options[:root],'config/environment.rb') ]
      libs.each do |lib|
        begin
          require lib  
        rescue LoadError => e
          abort "option rails is on, but could not load rails via '#{lib}'\nerror: #{e.message}"
        end
      end
    end
    
    
    # Setup logging
    @options[:log] ||= STDOUT
    if @options[:log] != STDOUT
      log_root = File.dirname(File.join(@options[:root], @options[:log])) 
      if !File.exists?(log_root)
        abort "dir for log file #{@options[:log]} does not exist"
      end
      @logger = Logger.new(File.join(@options[:root], @options[:log]))
    else
      @logger = Logger.new(@options[:log])
    end
    @logger.level = case
    when (!@options[:verbose] && !@options[:silent])
      Logger::INFO 
    when (@options[:verbose] && !@options[:silent])
      Logger::DEBUG
    when (!@options[:verbose] && @options[:silent])
      Logger::FATAL  
    when (@options[:verbose] && @options[:silent])
      Logger::WARN
    end
    @logger.formatter = Logger::Formatter.new
    
    # Setup locking
    @options[:lock_dir] ||= File.join @options[:root], "tmp/locks"
    if !File.exists?(@options[:lock_dir])
      logger.warn("You lock setting #{@options[:lock_dir]} doesn't exist - using /tmp")
      @options[:lock_dir] = '/tmp'
    end
  end
    
    
    
  def run
    base_name   = @options[:target]
    target      = File.join(@options[:root], "lib/cron/#{base_name}.rb") 
    lock_file   = File.join(@options[:lock_dir], "/#{base_name}.lock")
    
    if File.exists? lock_file
      stale     = false
      lock_pid  = File.read(lock_file)
      ps_output = nil
      
      unless lock_pid =~ /\d+/
        stale = true
      end
      
      unless stale
        begin
          ps_output = `ps -p #{lock_pid}` 
        rescue 
          logger.debug "ps failed, assuming stale"
          stale = true
        end
        
        if ps_output.split("\n").length < 1
          logger.debug "no ps output for pid #{lock_pid}, assuming stale"
          stale = true
        end
      end
      
      if stale
        logger.debug "cleaning stale pid #{lock_pid} from #{lock_file}"
        FileUtils.rm_f lock_file
      else
        logger.debug "#{base_name} is already running, skipping"
        exit
      end
    else
      logger.debug "there was no lock file"
    end

    begin
      pid = Process::pid
      File.open(lock_file, 'w') do |file|
        file << pid
      end
      logger.debug "wrote new pid #{pid} to lock file"
    rescue => e
      logger.debug "got an error writing to lock file"
      logger.info e.message
      logger.debug e.backtrace
      exit
    end
    
    
    # Load target script
    begin
      @others.flatten!
      @others.each_with_index do |arg, index|
        ARGV[index] = arg
      end 
      load target
      logger.fatal "#{target} successfully loaded via cron_wrapper"
    rescue LoadError => e
      logger.fatal "#{target} failed to load via cron_wrapper"
      logger.info e.message
      logger.debug e.backtrace
    ensure
      FileUtils.rm_f lock_file
    end
        
  end
  
  

end