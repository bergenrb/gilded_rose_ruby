require File.join(File.dirname(__FILE__), '../lib', 'gilded_rose')

def do_update_quality(org_items)
  items = org_items.map { |item| item.dup }
  GildedRose.new(items).update_quality()
  items.each_with_index { |item, idx| yield(item, org_items[idx]) }
  items
end

describe GildedRose do

  context "Zero day remining item" do
    let(:items) { [Item.new("foo", 0, 0)] }

    describe "#update_quality" do
      it "does not change the name" do
        do_update_quality(items) do |item, old_item|
          expect(item.name).to eq("foo")
        end
      end

      it "does update sell_in to -1" do
        do_update_quality(items) do |item, old_item|
          expect(item.sell_in).to eq(-1)
        end
      end
    end
  end

  context "Once the sell by date has passed, Quality degrades twice as fast" do

    it "should lower quality to 0 after sell_item with 2 as start" do
      do_update_quality([Item.new("foo", 0, 2)]) do |item, org_item|
        expect(item.quality).to eq(0)
      end
    end

    it "should lower quality to 5 after sell_item with 7 as start" do
      do_update_quality([Item.new("foo", 0, 7)]) do |item, org_item|
        expect(item.quality).to eq(5)
      end
    end
  end

  context "The Quality of an item is never negative" do
    it "should lower quality to 0 after sell_item with 0 as start" do
      do_update_quality([Item.new("foo", 0, 0)]) do |item, org_item|
        expect(item.quality).to eq(0)
      end
    end
  end

  context "Aged Brie actually increases in Quality the older it gets" do
    let(:items) { [Item.new("Aged Brie", 2, 2)] }

    it "should increase quality with 1 when aging" do
      do_update_quality(items) do |item, org_item|
        expect(item.quality).to eq(3)
      end
    end
  end

  context "The Quality of an item is never more than 50" do
    it "should increase quality with 1 when aging with 50 as max even for aged_brie" do
      do_update_quality([Item.new("Aged Brie", 2, 50)]) do |item, org_item|
        expect(item.quality).to eq(50)
      end
    end
  end

  context "'Sulfuras', being a legendary item, never has to be sold or decreases in Quality" do
    let (:sulfuras_items) { [Item.new("Sulfuras, Hand of Ragnaros", 1, 80)] }
    it "should not decrease sell_in when updating quality" do
      do_update_quality(sulfuras_items) do |item, org_item|
        expect(item.sell_in).to eq(org_item.sell_in)
      end
    end

    it "should not decrease quality when updating quality" do
      do_update_quality(sulfuras_items) do |item, org_item|
        expect(item.quality).to eq(org_item.quality)
      end
    end

    it "should have 80 as quality" do
      do_update_quality(sulfuras_items) do |item, org_item|
        expect(item.quality).to eq(80)
      end
    end

  end

  context "'Backstage passes', like aged brie, increases in Quality as it's SellIn value approaches;
          Quality increases by 2 when there are 10 days or less
                  and by 3 when there are 5 days or less
                  but Quality drops to 0 after the concert" do

    let(:items_10_days) { [Item.new("Backstage passes to a TAFKAL80ETC concert", 10, 2)] }
    let(:items_5_days) { [Item.new("Backstage passes to a TAFKAL80ETC concert", 5, 2)] }
    let(:items_0_days) { [Item.new("Backstage passes to a TAFKAL80ETC concert", 0, 2)] }

    it "should  increase Quality by 2 when there are between 6 and 10 days left" do
      do_update_quality(items_10_days) do |item, org_item|
        expect(item.quality).to eq(org_item.quality+2)
      end
    end

    it "should  increase Quality by 3 when there are between 0 and 5 days left" do
      do_update_quality(items_5_days) do |item, org_item|
        expect(item.quality).to eq(org_item.quality+3)
      end
    end

    it "should  drop Quality to 0 after the concert" do
      do_update_quality(items_0_days) do |item, org_item|
        expect(item.quality).to eq(0)
      end
    end

  end

  context '"Conjured" items degrade in Quality twice as fast as normal items' do
    it "should degrade twice as fast as normal" do
      do_update_quality([Item.new("Conjured", 1, 10)]) do |item, org_item|
        expect(item.quality).to eq(org_item.quality-2)
      end
    end
  end


end
