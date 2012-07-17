module Hoe::Version
  VERSION = '1.0.0'

  def define_version_tasks
    desc 'print current version'
    task 'version' do
      puts version
    end

    desc 'write version. VERSION=x.y.z'
    task 'version:write' do
      vers = ENV['VERSION'] or fail 'VERSION=x.y.z is required.'
      fail "unable to increment version to #{vers}" unless
        update_version vers
    end

    desc 'bump minor version.'
    task 'version:bump' do
      increment [0, 1, nil]
      task('version:write').invoke
    end

    desc 'bump major version'
    task 'version:bump:major' do
      increment [1, nil, nil]
      task('version:write').invoke
    end

    # alias
    task 'version:bump:minor' => 'version:bump'

    desc 'bump patch version'
    task 'version:bump:patch' do
      increment [0, 0, 1]
      task('version:write').invoke
    end
  end

  def increment mask
    segments = version.split('.')[0,3].map!{|p| p.to_i}

    mask.each_with_index do |m, i|
      case m
      when nil
        segments[i] = 0
      else
        segments[i] += m
      end
    end

    ENV['VERSION'] = segments.join '.'
  end

  def update_version vers
    # copied from hoe
    version_re = /VERSION += +([\"\'])(#{version})\1/

    spec.files.each do |file|
      next unless File.exist? file
      data = File.read_utf(file) rescue nil
      if data and data[version_re, 2] &&= vers
        #File.write(file, data)
        File.open(file, 'w'){|f| f.write data}
        return true
      end
    end

    false
  end
end
