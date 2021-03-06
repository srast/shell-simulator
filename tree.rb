class Tree
  def initialize(user_name)
    @current_dir = Folder.new('root', -1)
    initial_tree(user_name)
  end
  
  def fid_to_path(fid)
    arr = []
    current = Folder.find(fid)
    until current.id == 0
      arr << current.name
      current = Folder.find(current.parent)
    end
    "/" + arr.reverse.join("/")
  end

  def path_to_fid(path)
    absolute_path = path[0] == "/" # Checks to see if the path is absolute or not

    fid = absolute_path ? 0 : @current_dir.id
    path = path.split("/")
    path = path.drop(1) if absolute_path
    path.each do |item|
      if detected = Folder.all.detect { |f| f.name == item and f.parent == fid }
        fid = detected.id
      else
        puts "#{item}: No such file or directory"
      end
    end  
    fid
  end

  def pwd
    puts fid_to_path(@current_dir.id)
  end

  def ls(path = nil)
    # if a path is provided, retrive its fid.
    # Else fid will be the fid of the current path. 
    fid = path ? path_to_fid(path) : @current_dir.id

    folder = Folder.find(fid)
    folders = Folder.all.select { |f| f.parent == folder.id }.map { |f| f.name.light_blue }
    files = File.all.select { |f| f.parent == folder.id }.map { |f| f.name.yellow }
    result = folders + files

    # Format and print the result
    result.each_with_index do |item, index|
      print item + "\t\t"
      print "\n" if (index + 1) % 4 == 0 and index != (result.length - 1)
    end
    print "\n"
  end
  
  def cd(path)
    if path == '..'
      @current_dir = Folder.find(@current_dir.parent)
    else
      fid = path_to_fid(path)
      @current_dir = Folder.find(fid)
    end
  end
  
  def mkdir(path)
    path = path.split("/")
    name = path.pop
    path = path.join("/")
    fid = path_to_fid(path)
    Folder.new(name, fid)
  end
  
  def touch(path)
    path = path.split("/")
    name = path.pop
    path = path.join("/")
    fid = path_to_fid(path)
    File.new(name, fid)
  end

  def rm(path)
    path = path.split("/")
    name = path.pop
    path = path.join("/")
    fid = path_to_fid(path)
    File.delete(name: name, parent: fid)
  end

  def rmdir(path)
    fid = path_to_fid(path)
    path = path.split("/")
    folder_name = path.pop
    path = path.join("/")
    folder_parent = path_to_fid(path)
    File.delete(parent: fid)
    Folder.delete(name: folder_name, parent: folder_parent)
  end
  
  def initial_tree(user_name)
    ["bin", "boot", "dev", "etc", "home", "lib", "media", "mnt", "opt", "proc", "root", "run", "sbin", "srv", 
      "tmp", "usr", "var" ].each { |name| mkdir("/#{name}") }
    mkdir("/home/#{user_name}")
    ["Desktop", "Downloads", "Documents", "Music"].each { |name| mkdir("/home/#{user_name}/#{name}") }
  end
end