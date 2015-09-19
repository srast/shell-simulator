class Folder
  attr_accessor :name, :parent, :id
  @@id = -1
  @@folders = []

  def initialize(name, parent)
    @id = @@id = @@id + 1
    @name = name
    @parent = parent
    @@folders << self
  end

  def self.all
    @@folders
  end

  def self.find(id)
    @@folders.detect { |f| f.id == id }
  end

  def self.delete(par = {})
    selected = @@folders
    par.each do |key, value|
      selected = selected.select { |f| f.send(key) == value }
    end
    selected = selected[0]
    selected.parent = nil
  end
end