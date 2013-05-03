# tag cloud code inspired by this article
#  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/
class TagCloud
  attr_accessor :user, :divisor, :min

  def initialize(user, cut_off=nil)
    @user = user
    @cut_off = cut_off
  end

  def compute
    @tags = tags
    max, @min = 0, 0
    @tags.each { |t|
      max = [t.count.to_i, max].max
      @min = [t.count.to_i, @min].min
    }
    @divisor = ((max - @min) / levels) + 1
  end

  def tags
    return @tags if @tags
    params = [sql(@cut_off), user.id]
    if @cut_off
      params += [@cut_off, @cut_off]
    end
    @tags = Tag.find_by_sql(params).sort_by { |tag| tag.name.downcase }
  end

private
  def levels
    10
  end

  # TODO: parameterize limit
  def sql(cut_off=nil)
    query = "SELECT tags.id, tags.name, count(*) AS count"
    query << " FROM taggings, tags, todos"
    query << " WHERE tags.id = tag_id"
    query << " AND todos.user_id=? "
    query << " AND taggings.taggable_type='Todo' "
    query << " AND taggings.taggable_id=todos.id "
    if cut_off
      query << " AND (todos.created_at > ? OR "
      query << "      todos.completed_at > ?) "
    end
    query << " GROUP BY tags.id, tags.name"
    query << " ORDER BY count DESC, name"
    query << " LIMIT 100"
  end

end
