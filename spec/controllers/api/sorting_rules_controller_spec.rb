require 'rails_helper'

describe Api::SortingRulesController do
  let!(:sorting_rule) { FactoryBot.create :sorting_rule, name: 'Some Name' }
  let!(:test_sorting_rule) { FactoryBot.create :sorting_rule, name: 'Test' }
  let!(:tagged_sorting_rules) { FactoryBot.create_list :sorting_rule, 2, tag_ids: [tag.id] }
  let!(:categorised_sorting_rules_1) { FactoryBot.create_list :sorting_rule, 2, category_id: category_1.id }
  let!(:categorised_sorting_rules_2) { FactoryBot.create_list :sorting_rule, 2, category_id: category_2.id }
  let!(:categorised_sorting_rules_3) { FactoryBot.create_list :sorting_rule, 2, category_id: category_3.id }
  let!(:category_1) { FactoryBot.create :category, type: 'Flexible' }
  let!(:category_2) { FactoryBot.create :category, type: 'Flexible' }
  let!(:category_3) { FactoryBot.create :category, type: 'Essential' }

  let!(:tag) { FactoryBot.create :tag }

  describe 'GET index' do
    context 'no filters' do
      before { get :index }

      it { should respond_with :success }

      it 'returns all sorting_rules' do
        expect(assigns(:sorting_rules)).to match_array [sorting_rule, test_sorting_rule, tagged_sorting_rules, categorised_sorting_rules_1, categorised_sorting_rules_2, categorised_sorting_rules_3].flatten
      end
    end

    context 'filter search query' do
      before do
        get :index, query: 'test'
      end

      it { should respond_with :success }

      it 'filters sorting rules by search query' do
        expect(assigns(:sorting_rules)).to match_array [test_sorting_rule]
      end
    end

    context 'filter with category' do
      before do
        get :index, category_id: category_1.id
      end

      it { should respond_with :success }

      it 'filters sorting rules by category_id' do
        expect(assigns(:sorting_rules)).to match_array categorised_sorting_rules_1
      end
    end

    context 'filter with category type' do
      before do
        get :index, category_type: 'Flexible'
      end

      it { should respond_with :success }

      it 'filters sorting rules by category_type' do
        expect(assigns(:sorting_rules)).to match_array categorised_sorting_rules_1 + categorised_sorting_rules_2
      end
    end

    context 'filter with tags' do
      before do
        get :index, tag_ids: tag.id
      end

      it { should respond_with :success }

      it 'filters sorting rules by tag id' do
        expect(assigns(:sorting_rules)).to match_array tagged_sorting_rules
      end
    end
  end

  describe 'GET show' do
    before { get :show, id: sorting_rule.id }

    it { should respond_with :success }

    it 'returns the sorting_rule' do
      expect(assigns(:sorting_rule)).to eq sorting_rule
    end
  end

  describe 'POST create' do
    def valid_request
      post :create,
        name: 'New Name',
        contains: 'Foobar',
        category_id: category_1.id
    end

    it 'responds with 200' do
      valid_request
      expect(subject).to respond_with(:success)
    end

    it 'creates a sorting_rule' do
      expect do
        valid_request
      end.to change(SortingRule, :count).by(1)
    end
  end

  describe 'PUT update' do
    def valid_request
      put :update,
        id: sorting_rule.id,
        name: 'Some New Name'
    end

    it 'responds with 200' do
      valid_request
      expect(subject).to respond_with(:success)
    end

    it 'updates the name' do
      expect do
        valid_request
      end.to change { sorting_rule.reload.name }.from('Some Name').to('Some New Name')
    end
  end

  describe 'DELETE destroy' do
    def valid_request
      delete :destroy,
        id: sorting_rule.id
    end

    it 'responds with 204' do
      valid_request
      expect(subject).to respond_with(:no_content)
    end

    it 'deletes the sorting_rule' do
      expect do
        valid_request
      end.to change(SortingRule, :count).by(-1)
    end
  end
end
