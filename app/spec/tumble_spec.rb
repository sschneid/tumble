describe 'TumbleLog' do
    include Rack::Test::Methods

    def app
      @app ||= Sinatra::Application
    end

    FakeWeb.allow_net_connect = %r[^https?://localhost:5984]

    let(:quoteid) { 'd150735ece7927beb570b830bd00414d' }
    let(:linkid)  { 'd150735ece7927beb570b830bd00456a' }

    describe 'frontpage' do
      it 'should load the tracker for google analytics' do
        get '/'
        last_response.should be_ok
      end

      it 'should allow a user to page forward and backward' do
        get '/'
        last_response.should be_ok
        #last_response.body.should contain_prev_nav
        #last_response.body.should_not contain_next_nav
      end

#       it 'should include quotes from the database'
#       it 'should include links from the database'
#       it 'should include fotos from phlicker'
#       it 'should be able to search links, quotes, and photos'
#       it 'should be backwards compatible with the original cgi (specification)'
    end

#      describe 'setup' do
#        it 'should create a database if none is available'
#        it 'should install the design docs into the database'
#      end

    describe 'api' do
      describe '_page' do
        it 'should return 10 items at a time' do
          get '/page'
          last_response.should be_ok
          j = JSON.parse(last_response.body)
          j.should be_an(Array)
          j.should have(10).items
        end

        it 'should skip items' do
          get '/page/0'
          list1 = JSON.parse(last_response.body).collect {|i| i['_id']}.compact
          get '/page/2'
          list2 = JSON.parse(last_response.body).collect {|i| i['_id']}.compact
          diff=list1&list2
          diff.should have(0).items
        end

      end

      describe '_quote' do
        # 'http://tumble.wcyd.org/quote/?quote=' . "$quote" . "&author=$author")
        it 'should accept a quote post' do
          post '/quote', { :author => 'Yoda', :quote => 'Do or do not, there is no try'}
          last_response.status.should eql(201)
          last_response.headers['ETag'].should_not be_nil
        end

        it 'should retrieve a quote' do
          get "/quote/#{quoteid}"
          last_response.should be_ok
          JSON.parse(last_response.body).should be_a(Hash)
        end

      end

      describe '_irclink' do
        it 'should accept a link' do
          testuri = 'http://www.google.com'
          FakeWeb.register_uri(:head, testuri, :status => [200, "OK"])
          FakeWeb.register_uri(:get, testuri, :status => [200, "OK"], :body => 'spec/fixtures/google.html')
          post "/irclink", {:user => 'Aziz Shamim', :url => testuri }
          last_response.status.should eql(201)
          last_response.headers['ETag'].should_not be_nil
          last_response.body.should_not be_empty
        end

        it 'should redirect to the link' do
          get "/irclink/#{linkid}"
          last_response.status.should eql(301)
          last_response.headers['Location'].should_not be_nil
        end

        it 'should track how many times the link is clicked (redirected)' do
          get "/irclink/#{linkid}"
          pre_click = last_response.headers['clicks'].to_i
          get "/irclink/#{linkid}"
          post_click = last_response.headers['clicks'].to_i
          diff = post_click - pre_click
          diff.should eql(1)
        end

      end

      describe '_photos' do
        it 'should accept a photo' do
          post '/image', 'file' => Rack::Test::UploadedFile.new('spec/fixtures/placekitten.jpg', 'image/jpeg')
          last_response.status.should eql(201)
          last_response.headers['ETag'].should_not be_nil
          last_response.headers['Location'].should_not be_nil
        end

#         it 'should retrieve a photo'
#         it 'should include metadata culled from exif information'
#         it 'should include a caption'
      end

#       describe '_flickr' do
#         it 'should include photos from a configured flickr feed'
#         it 'should include the photo tag'
#         it 'should include the sender of the photo'
#         it 'should include a link to the photo on flickr'
#       end

    end

end