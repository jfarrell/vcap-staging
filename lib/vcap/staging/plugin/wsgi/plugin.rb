class WsgiPlugin < StagingPlugin
  include PipSupport

  REQUIREMENTS = ['gunicorn']

  def stage_application
    Dir.chdir(destination_directory) do
      create_app_directories
      copy_source_files
      create_startup_script
      create_stop_script
      create_gunicorn_config
    end
  end

  def start_command
    cmds = []
    if uses_pip?
      cmds << install_requirements
    end
    cmds << "../python/bin/gunicorn -c ../gunicorn.config wsgi:application"
    cmds.join("\n")
  end

  private
  def startup_script
    generate_startup_script do
      setup_python_env(REQUIREMENTS)
    end
  end

  def stop_script
    generate_stop_script
  end

  def create_gunicorn_config
    File.open('gunicorn.config', 'w') do |f|
      f.write <<-EOT
import os
bind = "0.0.0.0:%s" % os.environ['VCAP_APP_PORT']
loglevel = "debug"
      EOT
    end
  end
end
