require 'swagger_helper'
require 'dotenv/load'

token = ENV['BEARER_TOKEN']

describe 'Subscriber API' do

  path '/api/v1/subscribers' do

    post 'Creates a subscriber' do
      tags 'Subscriber'
      consumes 'application/json', 'application/xml'
      parameter name: :subscriber, in: :body, schema: {
        type: :object,
        properties: {
          firstname: { type: :string },
          lastname: { type: :string },
          email: { type: :string },
          phone: { type: :string },
          facebook_id: { type: :string }
        },
        required: [ 'firstname', 'facebook_id' ]
      }

      response '200', 'subscriber created' do
        let(:subscriber) { { firsname: 'Fred', facebook_id: 'XXXX' } }
        run_test!
      end

    #   response '422', 'invalid request' do
    #     let(:pet) { { name: 'foo' } }
    #     run_test!
    #   end
    end
  end

  path '/api/v1/subscribers/{id}' do

    get 'Retrieves a subscriber' do
      tags 'Subscriber'
      produces 'application/json', 'application/xml'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'name found' do
        schema type: :object,
          properties: {
            id: { type: :integer, },
            name: { type: :string },
            photo_url: { type: :string },
            status: { type: :string }
          },
          required: [ 'id', 'firstname', 'facebook_id' ]

        let(:id) { Subscriber.create(firstname: 'foo', facebook_id: 'bar').id }
        run_test!
      end

      response '404', 'pet not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end