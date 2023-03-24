require 'rails_helper'

describe Api::TransactionsController do
  let!(:transaction) { FactoryBot.create :transaction, name: 'Transaction Name' }
  let!(:account) { FactoryBot.create :account }

  describe 'GET index' do
    let!(:account_transactions) { FactoryBot.create_list :transaction, 2, account: account }
    let!(:other_transactions) { FactoryBot.create_list :transaction, 2 }
    let!(:sorted_transactions) { FactoryBot.create_list :transaction, 2 }
    let!(:transactions_for_review) { FactoryBot.create_list :transaction, 2 }
    let!(:all_transactions) do
      [
        transaction,
        account_transactions,
        other_transactions,
        sorted_transactions,
        transactions_for_review
      ].flatten
    end
    let!(:unsorted_transactions) do
      [
        transaction,
        account_transactions,
        other_transactions
      ].flatten
    end
    let!(:category) { FactoryBot.create :category, type: 'Essential' }
    let!(:other_category) { FactoryBot.create :category, type: 'Income' }

    before do
      sorted_transactions.each do |t|
        t.create_sorted_transaction(
          account: t.account,
          category: category,
          name: 'Test',
          review: false
        )
      end

      transactions_for_review.each do |t|
        t.create_sorted_transaction(
          account: t.account,
          category: other_category,
          name: t.search,
          review: true
        )
      end
    end

    context 'no filters' do
      before { get :index }

      it { should respond_with :success }

      it 'returns all transactions' do
        expect(assigns(:transactions)).to match_array all_transactions
      end
    end

    context 'filter by account_id' do
      before do
        get :index, account_id: account.id
      end

      it { should respond_with :success }

      it 'returns all transactions for the account' do
        expect(assigns(:transactions)).to match_array account_transactions
      end
    end

    context 'filter sorted' do
      before do
        get :index, sorted: true
      end

      it { should respond_with :success }

      it 'returns sorted transactions' do
        expect(assigns(:transactions)).to match_array [sorted_transactions, transactions_for_review].flatten
      end
    end

    context 'filter unsorted' do
      before do
        get :index, unsorted: true
      end

      it { should respond_with :success }

      it 'returns unsorted transactions' do
        expect(assigns(:transactions)).to match_array unsorted_transactions
      end
    end

    context 'filter flagged for review' do
      before do
        get :index, review: true
      end

      it { should respond_with :success }

      it 'returns transactions flagged for review' do
        expect(assigns(:transactions)).to match_array transactions_for_review
      end
    end

    context 'filter not flagged for review' do
      before do
        get :index, review: false
      end

      it { should respond_with :success }

      it 'returns transactions not flagged for review' do
        expect(assigns(:transactions)).to match_array sorted_transactions
      end
    end

    context 'filter search query' do
      before do
        get :index, query: 'test'
      end

      it { should respond_with :success }

      it 'filters transactions by search query' do
        expect(assigns(:transactions)).to match_array sorted_transactions
      end
    end

    context 'filter with category' do
      before do
        get :index, category_id: category.id
      end

      it { should respond_with :success }

      it 'filters transactions by category_id' do
        expect(assigns(:transactions)).to match_array sorted_transactions
      end
    end

    context 'filter with category type' do
      before do
        get :index, category_type: other_category.type
      end

      it { should respond_with :success }

      it 'filters transactions by category_id' do
        expect(assigns(:transactions)).to match_array transactions_for_review
      end
    end

    context 'filter between dates' do
      let!(:transaction_during) { FactoryBot.create :transaction, posted_at: Date.parse('2012-04-10') }

      before do
        get :index, date_from: '2012-04-01', date_to: '2012-04-30'
      end

      it { should respond_with :success }

      it 'filters transactions between dates' do
        expect(assigns(:transactions)).to match_array [transaction_during]
      end
    end

    context 'filter with tags' do
      let!(:tag) { FactoryBot.create :tag }
      let!(:transaction_match_1) { FactoryBot.create :transaction, sorted_transaction: FactoryBot.create(:sorted_transaction, tag_ids: [tag.id]) }
      let!(:transaction_match_2) { FactoryBot.create :transaction, sorted_transaction: FactoryBot.create(:sorted_transaction, tag_ids: [tag.id]) }

      before do
        get :index, tag_ids: tag.id
      end

      it { should respond_with :success }

      it 'filters transactions by tag id' do
        expect(assigns(:transactions)).to match_array [transaction_match_1, transaction_match_2]
      end
    end
  end

  describe 'GET show' do
    before { get :show, id: transaction.id }

    it { should respond_with :success }

    it 'returns the transaction' do
      expect(assigns(:transaction)).to eq transaction
    end
  end

  describe 'POST create' do
    def valid_request
      attributes = FactoryBot.attributes_for(:transaction)
      attributes[:account_id] = account.id
      post :create, attributes
    end

    it 'responds with 200' do
      valid_request
      expect(subject).to respond_with(:success)
    end

    it 'creates a transaction' do
      expect do
        valid_request
      end.to change(Transaction, :count).by(1)
    end
  end

  describe 'PUT update' do
    def valid_request
      put :update,
        id: transaction.id,
        name: 'New Transaction Name'
    end

    it 'responds with 200' do
      valid_request
      expect(subject).to respond_with(:success)
    end

    it 'updates the name' do
      expect do
        valid_request
      end.to change { transaction.reload.name }.from('Transaction Name').to('New Transaction Name')
    end
  end

  describe 'DELETE destroy' do
    def valid_request
      delete :destroy,
        id: transaction.id
    end

    it 'responds with 204' do
      valid_request
      expect(subject).to respond_with(:no_content)
    end

    it 'deletes the transaction' do
      expect do
        valid_request
      end.to change(Transaction, :count).by(-1)
    end
  end

  describe 'POST sort' do
    # FIXME: this needs more tests

    it 'responds with 200' do
      post :sort
      expect(subject).to respond_with(:success)
    end

    context 'with account_id' do
      let(:account) { FactoryBot.create :account }
      it 'responds with 200' do
        post :sort, account_id: account.id
        expect(subject).to respond_with(:success)
      end
    end
  end
end
