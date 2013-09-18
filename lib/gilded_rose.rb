class GildedRose
  NON_CHANING_ITEMS=["Sulfuras, Hand of Ragnaros"]
  INCREASING_ITEMS=["Aged Brie", "Backstage passes to a TAFKAL80ETC concert"]
  AGING_ITEMS=["Aged Brie"]
  BACKSTAGE_PASS_ITEM=["Backstage passes to a TAFKAL80ETC concert"]
  DOUBLE_DEGRADE_ITEMS=["Conjured"]

  def initialize(items)
    @items = items
  end

  def update_quality()
    @items.each { |item| update_item(item) }
  end

  def update_item(item)
    return item if is_non_changing_item?(item)

    item.sell_in = item.sell_in - 1

    update_item_quality(item, (calc_x_factor(item) * calc_normal_factor(item)) + calc_aging_factor(item) + calc_backstage_factor(item) )
  end

  def update_item_quality(item, factor)
    item.quality = item.quality + factor if (item.quality + factor >= 0) && (item.quality + factor <= 50)
    item
  end

  # Calc misc item factors

  # Calculation of normal quality factor
  def calc_normal_factor(item)
    quality_normal_factor(is_increasing_item?(item))
  end

  def calc_aging_factor(item)
    quality_aging_factor(item.sell_in, is_aging_item?(item))

  end

  def calc_backstage_factor(item)
    return 0 unless is_backstage_pass_item?(item)

    quality_backstage_pass_factor(item.sell_in, item.quality)
  end

  def calc_x_factor(item)
    is_double_degrade_item?(item) ? 2 : 1
  end

  # Actual factors based on type

  def quality_normal_factor(is_increasing_item)
    is_increasing_item ? 1 : -1
  end


  def quality_aging_factor(sell_in, is_aging_item)
    if sell_in < 0
      is_aging_item ? 1 : -1
    else
      0
    end
  end

  #
  def quality_backstage_pass_factor(sell_in, quality)
    if sell_in > 0
      factor_from_remaining_days(sell_in)
    else
      -quality
    end

  end

  private

  def factor_from_remaining_days(remaning_days)
    return 2 if remaning_days < 6
    return 1 if remaning_days < 11
    0
  end


  # Categories of items

  def is_non_changing_item?(item)
    NON_CHANING_ITEMS.include?(item.name)
  end

  def is_increasing_item?(item)
    INCREASING_ITEMS.include?(item.name)
  end

  def is_aging_item?(item)
    AGING_ITEMS.include?(item.name)
  end

  def is_backstage_pass_item?(item)
    BACKSTAGE_PASS_ITEM.include?(item.name)
  end

  def is_double_degrade_item?(item)
    DOUBLE_DEGRADE_ITEMS.include?(item.name)
  end

end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
