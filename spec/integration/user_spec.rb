#All of the endpoints down below were found using rails. If you'd like to find these type localhost/k with CHORDS running.

require 'swagger_helper'

describe 'Users API' do

  #GET for /users/sign_out - WORKING
  path '/users/sign_out' do

    get 'Signs you out' do
      tags 'Users'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #GET for /users/password/new - WORKING
  path '/users/password/new' do

    get 'Takes you to the page to change your password' do
      tags 'Users'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end


  #GET for /users/edit - WORKING
  path '/users/edit' do

    get 'to the users password edit page' do
      tags 'Users'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end


  #GET for /users - WORKING
  path '/users' do

    get 'post to users page' do
      tags 'Users'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

end