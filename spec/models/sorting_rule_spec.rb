require 'rails_helper'

describe SortingRule do
  it { should have_db_column(:contains).of_type(:string).with_options(null: false) }

  it { should have_db_column(:category_id).of_type(:integer).with_options(null: false) }

  it { should have_db_column(:name).of_type(:string).with_options(default: nil) }

  it { should have_db_column(:review).of_type(:boolean).with_options(default: false, null: false) }

  it { should have_db_column(:tag_ids).of_type(:integer).with_options(array: true) }

  it { should have_db_index(:contains).unique(:true) }

  it { should validate_presence_of :contains }

  it { should validate_presence_of :category }

  it { should belong_to :category }

  describe 'tags' do
    let!(:tag1) { FactoryBot.create :tag, name: 'First Tag' }

    let!(:tag2) { FactoryBot.create :tag, name: 'Second Tag' }

    describe '.tags' do
      subject { FactoryBot.build :sorting_rule, tag_ids: [tag1.id, tag2.id] }

      specify do
        expect(subject.tags).to eq [tag1, tag2]
      end
    end

    describe '.tags=' do
      subject { FactoryBot.build :sorting_rule, tag_ids: [] }

      context 'a list of tag models' do
        before do
          subject.tags = [tag1, tag2]
        end

        specify do
          expect(subject.tag_ids).to eq [tag1.id, tag2.id]
        end
      end

      context 'a string of tag names' do
        before do
          subject.tags = 'First Tag, Second Tag'
        end

        specify do
          expect(subject.tag_ids).to eq [tag1.id, tag2.id]
        end
      end

      context 'an unexpected type' do
        specify do
          expect do
            subject.tags = { foo: 'bar' }
          end.to raise_error StandardError, 'unknown tag list'
        end
      end
    end

    describe '.tag_list' do
      subject { FactoryBot.build :sorting_rule, tag_ids: [tag1.id, tag2.id] }

      specify do
        expect(subject.tag_list).to eq [tag1.name, tag2.name]
      end
    end

    describe '.tag_list=' do
      subject { FactoryBot.build :sorting_rule, tag_ids: [] }

      before do
        subject.tag_list = [tag1.name, tag2.name]
      end

      specify do
        expect(subject.tag_ids).to eq [tag1.id, tag2.id]
      end
    end
  end

  describe '#with_category' do
    let!(:sorting_rules_1) { FactoryBot.create_list :sorting_rule, 2, category_id: category_1.id }
    let!(:sorting_rules_2) { FactoryBot.create_list :sorting_rule, 2, category_id: category_2.id }
    let!(:category_1) { FactoryBot.create :category }
    let!(:category_2) { FactoryBot.create :category }

    it 'only includes sorting rules with the correct category' do
      expect(described_class.with_category(category_1.id)).to match_array sorting_rules_1
    end
  end

  describe '#with_category_type' do
    let!(:sorting_rules_1) { FactoryBot.create_list :sorting_rule, 2, category_id: category_1.id }
    let!(:sorting_rules_2) { FactoryBot.create_list :sorting_rule, 2, category_id: category_2.id }
    let!(:sorting_rules_3) { FactoryBot.create_list :sorting_rule, 2, category_id: category_3.id }
    let!(:category_1) { FactoryBot.create :category, type: 'Flexible' }
    let!(:category_2) { FactoryBot.create :category, type: 'Flexible' }
    let!(:category_3) { FactoryBot.create :category, type: 'Essential' }

    it 'only includes sorting rules with the correct category type' do
      expect(described_class.with_category_type('Flexible')).to match_array sorting_rules_1 + sorting_rules_2
    end
  end

  describe '#search_query' do
    let!(:sorting_rule_match) { FactoryBot.create :sorting_rule, name: 'Test Foobar' }
    let!(:sorting_rule_no_match) { FactoryBot.create :sorting_rule, name: 'Foobar' }

    it 'only includes sorting rule that match the search query' do
      expect(described_class.search_query('Test')).to match_array [sorting_rule_match]
    end

    it 'only includes sorting rule that match the search query, case insensitive' do
      expect(described_class.search_query('test')).to match_array [sorting_rule_match]
    end
  end

  describe '#with_tags' do
    let!(:tag_1) { FactoryBot.create :tag }
    let!(:tag_2) { FactoryBot.create :tag }
    let!(:sorting_rule_match_1) { FactoryBot.create :sorting_rule, tag_ids: [tag_1.id, tag_2.id] }
    let!(:sorting_rule_match_2) { FactoryBot.create :sorting_rule, tag_ids: [tag_1.id, tag_2.id] }
    let!(:sorting_rule_no_match) { FactoryBot.create :sorting_rule }

    it 'only includes sorting rule that have all the correct tags' do
      expect(described_class.with_tags([tag_1.id, tag_2.id])).to match_array [sorting_rule_match_1, sorting_rule_match_2]
    end

    it 'only includes sorting rule that have one correct tag' do
      expect(described_class.with_tags([tag_1.id])).to match_array [sorting_rule_match_1, sorting_rule_match_2]
    end
  end
end
