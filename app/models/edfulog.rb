class Edfulog < ActiveRecord::Base


  # todo: put in config file
  @@separator = "/:/"


  def self.separator
    return @@separator
  end

  def initialize (level, edfutype, text, column, old, new, uid)
    super()


    self.level  = level
    self.edfutype   = edfutype
    self.text   = text
    self.column = column
    self.old    = old
    self.new    = new
    self.uid    = uid

    self.save

    # ---

    self.log
  end


  def log
    case self.level
      when "ERROR"
        logger.error self.to_s
      when "INFO"
        logger.info self.to_s
      when "DEBUG"
        logger.debug self.to_s
      when "WARN"
        logger.warn self.to_s
      when "FATAL"
        logger.fatal self.to_s
    end
  end

  def to_s
    return "#{self.edfutype} #{@@separator} #{self.text} #{@@separator} #{self.column} #{@@separator} #{self.old} #{@@separator} #{self.new} #{@@separator} #{self.uid}\n"
  end

end
