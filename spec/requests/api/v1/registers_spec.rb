describe "/api/v1/registers" do
  let(:page_overload) { 11 }
  modes = ["input", "output"]
  #modes = ["input"]
  modes.each do |mode|
    describe "#{mode}s" do
      klass = "Register::#{mode.camelize}".constantize

      describe "read" do
        it "get world-readable #{mode} register with and without token" do
          access_token      = Fabricate(:simple_access_token)
          register          = Fabricate("#{mode}_register_readable_by_world")

          get_without_token "/api/v1/registers/#{register.id}"
          expect(response).to have_http_status(200)
          get_with_token "/api/v1/registers/#{register.id}", access_token.token
          expect(response).to have_http_status(200)
        end


        ["friends", "community", "members"].each do |user_type|
          it "does not get a #{user_type}-readable #{mode} register without token" do
            register = Fabricate("#{mode}_register_readable_by_#{user_type}")
            get_without_token "/api/v1/registers/#{register.id}"
          end
        end


        it "get community-readable #{mode} register with community token" do
          register     = Fabricate("#{mode}_register_readable_by_community")
          access_token = Fabricate(:simple_access_token)

          get_with_token "/api/v1/registers/#{register.id}", access_token.token
          expect(response).to have_http_status(200)
        end


        ["friends", "members"].each do |user_type|
          it "does not get #{user_type} readable register with community token" do
            register      = Fabricate("#{mode}_register_readable_by_#{user_type}")
            access_token  = Fabricate(:simple_access_token)
            get_with_token "/api/v1/registers/#{register.id}", access_token.token
            expect(response).to have_http_status(403)
          end
        end


        it "get friends-readable #{modes.join(" and ")} register by manager friends or by members" do
          register          = Fabricate("#{mode}_register_readable_by_friends")
          member_token      = Fabricate(:simple_access_token)
          member_user       = User.find(member_token.resource_owner_id)
          access_token      = Fabricate(:access_token_with_friend)
          token_user        = User.find(access_token.resource_owner_id)
          token_user_friend = token_user.friends.first
          token_user_friend.add_role(:manager, register)
          member_user.add_role(:member, register)

          get_with_token "/api/v1/registers/#{register.id}", access_token.token
          expect(response).to have_http_status(200)
          get_with_token "/api/v1/registers/#{register.id}", member_token.token
          expect(response).to have_http_status(200)
        end

        it "get members-readable #{modes.join(" and ")} register by members but not by manager friends" do
          register          = Fabricate("#{mode}_register_readable_by_members")
          member_token      = Fabricate(:simple_access_token)
          member_user       = User.find(member_token.resource_owner_id)
          access_token      = Fabricate(:access_token_with_friend)
          token_user        = User.find(access_token.resource_owner_id)
          token_user_friend = token_user.friends.first
          token_user_friend.add_role(:manager, register)
          member_user.add_role(:member, register)

          get_with_token "/api/v1/registers/#{register.id}", access_token.token
          expect(response).to have_http_status(403)
          get_with_token "/api/v1/registers/#{register.id}", member_token.token
          expect(response).to have_http_status(200)
        end


        it "does gets a #{mode} register with full access token as admin" do
          access_token  = Fabricate(:full_access_token_as_admin)
          register = Fabricate("#{mode}_register")
          get_with_token "/api/v1/registers/#{register.id}", access_token.token
          expect(response).to have_http_status(200)
        end


        it "does gets a #{mode} register as friend" do
          access_token = Fabricate("access_token_with_friend_and_#{mode}_register")

          register2 = klass.last
          get_with_token "/api/v1/registers/#{register2.id}", access_token.token
          expect(response).to have_http_status(200)

          register1 = klass.first
          get_with_token "/api/v1/registers/#{register1.id}", access_token.token
          expect(response).to have_http_status(200)

          register3 = Fabricate("#{mode}_register") # register from unknown user
          get_with_token "/api/v1/registers/#{register3.id}", access_token.token
          expect(response).to have_http_status(403)
        end
      end

      describe "create" do

        it "does creates a #{mode} register with full access token as admin" do
          access_token  = Fabricate(:full_access_token_as_admin)
          register      = Fabricate.build("#{mode}_register")
          meter         = Fabricate(:meter)
          request_params = {
            uid:  register.uid,
            readable: register.readable,
            name: register.name,
            meter_id: meter.id
          }.to_json

          post_with_token "/api/v1/registers/#{mode}s", request_params, access_token.token

          expect(response).to have_http_status(201)
          expect(response.headers["Location"]).to eq json["data"]["id"]
          expect(json["data"]["attributes"]["uid"]).to eq(register.uid)
          expect(json["data"]["attributes"]["mode"]).to eq(register.mode)
          expect(json["data"]["attributes"]["direction"]).to eq(mode.sub(/put/, ''))
          expect(json["data"]["attributes"]["readable"]).to eq(register.readable)
          expect(json["data"]["attributes"]["meter-id"]).to eq(meter.id)
          expect(json["data"]["attributes"]["name"]).to eq(register.name)
        end

        it "does not creates a #{mode} register without token" do
          register     = Fabricate.build("#{mode}_register")
          meter        = Fabricate.build(:meter)
          request_params = {
            uid:  register.uid,
            readable: register.readable,
            name: register.name,
            meter_id: meter.id
          }.to_json
          post_without_token "/api/v1/registers/#{mode}s", request_params
          expect(response).to have_http_status(401)
        end


        it "does not creates a #{mode} register with missing parameters" do
          register       = Fabricate.build("#{mode}_register")
          access_token   = Fabricate(:full_access_token)
          meter          = Fabricate(:meter)
          request_params = {
            readable: register.readable,
            name: register.name,
            meter_id: meter.id
          }
          request_params.keys.each do |name|
            params = request_params.reject { |k,v| k == name }
            post_with_token "/api/v1/registers/#{mode}s", params.to_json, access_token.token
            expect(response).to have_http_status(422)
            json["errors"].each do |error|
              expect(error["source"]["pointer"]).to eq "/data/attributes/#{name}"
              expect(error["title"]).to eq "Invalid Attribute"
              expect(error["detail"]).to eq "#{name} is missing"
            end
          end
        end


        it "does not creates a #{mode} register with invalid parameters" do
          register       = Fabricate.build("#{mode}_register")
          access_token   = Fabricate(:full_access_token)
          meter          = Fabricate(:meter)
          request_params = {
            readable: register.readable,
            name: register.name,
            meter_id: meter.id
          }
          request_params.keys.each do |key|
            next if key == :meter_id
            params = request_params.dup
            params[key] = "a" * 2000
            post_with_token "/api/v1/registers/#{mode}s", params.to_json, access_token.token
            expect(response).to have_http_status(422)
            json["errors"].each do |error|
              expect(error["source"]["pointer"]).to eq "/data/attributes/#{key}"
              expect(error["title"]).to eq "Invalid Attribute"
              expect(error["detail"]).to match /#{key}/
            end
          end
        end


        it "does not creates a #{mode} register with invalid meter_id" do
          register       = Fabricate.build("#{mode}_register")
          access_token   = Fabricate(:full_access_token)
          request_params = {
            readable: register.readable,
            name: register.name,
            meter_id: "asd-dsa"
          }
          post_with_token "/api/v1/registers/#{mode}s", request_params.to_json, access_token.token
          expect(response).to have_http_status(404)
        end



        [:simple_access_token, :full_access_token, :smartmeter_access_token].each do |token|
          it "creates a #{mode} register with #{token}" do
            access_token = Fabricate(token)
            register     = Fabricate.build("#{mode}_register")
            meter        = Fabricate(:meter)

            request_params = {
              uid:  register.uid,
              readable: register.readable,
              name: register.name,
              meter_id: meter.id
            }.to_json

            post_with_token "/api/v1/registers/#{mode}s", request_params, access_token.token
            expect(response).to have_http_status(201)
            expect(response.headers["Location"]).to eq json["data"]["id"]

            expect(json["data"]["attributes"]["uid"]).to eq(register.uid)
            expect(json["data"]["attributes"]["mode"]).to eq(register.mode)
            expect(json["data"]["attributes"]["readable"]).to eq(register.readable)
            expect(json["data"]["attributes"]["meter-id"]).to eq(meter.id)
            expect(json["data"]["attributes"]["name"]).to eq(register.name)
          end
        end

      end

      describe "update" do

        it "does not update a #{mode} register with invalid meter_id" do
          register        = Fabricate("#{mode}_register")
          access_token    = Fabricate(:full_access_token_as_admin)
          patch_with_token "/api/v1/registers/#{mode}s/#{register.id}", { meter_id: "asddsa"}.to_json, access_token.token
          expect(response).to have_http_status(404)
        end


        it "does not update a #{mode} register with invalid parameters" do
          register      = Fabricate("#{mode}_register")
          access_token  = Fabricate(:full_access_token_as_admin)
          [
            :readable,
            :name
          ].each do |name|
            params = { "#{name}": "a" * 2000 }
            patch_with_token "/api/v1/registers/#{mode}s/#{register.id}", params.to_json, access_token.token
            expect(response).to have_http_status(422)
            json["errors"].each do |error|
              expect(error["source"]["pointer"]).to eq "/data/attributes/#{name}"
              expect(error["title"]).to eq "Invalid Attribute"
              expect(error["detail"]).to match /#{name}/
            end
          end
        end

        it "updates a #{mode} register name with token" do
          register      = Fabricate("#{mode}_register_with_manager")
          manager       = register.managers.first
          access_token  = Fabricate(:simple_access_token, resource_owner_id: manager.id)
          meter         = Fabricate(:meter)
          request_params = {
            id: register.id,
            uid: register.uid,
            readable: register.readable,
            name: "#{register.name} updated",
            meter_id: meter.id
          }.to_json

          patch_with_token "/api/v1/registers/#{mode}s/#{register.id}", request_params, access_token.token

          expect(response).to have_http_status(200)
          expect(json["data"]["attributes"]["uid"]).to eq(register.uid)
          expect(json["data"]["attributes"]["mode"]).to eq(register.mode)
          expect(json["data"]["attributes"]["readable"]).to eq(register.readable)
          expect(json["data"]["attributes"]["meter-id"]).to eq(meter.id)
          expect(json["data"]["attributes"]["name"]).to eq("#{register.name} updated")
        end


        it "does update a #{mode} register with full access token as admin" do
          register = Fabricate("#{mode}_register_with_manager")
          access_token  = Fabricate(:full_access_token_as_admin)
          request_params = {
            id: register.id,
            uid: register.uid,
            mode: register.mode,
            readable: register.readable,
            name: "#{register.name} updated",
          }.to_json

          patch_with_token "/api/v1/registers/#{mode}s/#{register.id}", request_params, access_token.token

          expect(response).to have_http_status(200)
          expect(json["data"]["attributes"]["uid"]).to eq(register.uid)
          expect(json["data"]["attributes"]["mode"]).to eq(register.mode)
          expect(json["data"]["attributes"]["readable"]).to eq(register.readable)
          expect(json["data"]["attributes"]["name"]).to eq("#{register.name} updated")
        end


        it "does not update a #{mode} register without token" do
          register = Fabricate("#{mode}_register_with_manager")
          meter    = Fabricate(:meter)
          request_params = {
            id: register.id,
            uid: register.uid,
            mode: register.mode,
            readable: register.readable,
            name: "#{register.name} updated",
            meter_id: meter.id
          }.to_json

          patch_without_token "/api/v1/registers/#{mode}s", request_params

          expect(response).to have_http_status(401)
        end

      end

      describe "delete" do
        it "does delete a #{mode} register with manager_token" do
          register = Fabricate("#{mode}_register")
          access_token  = Fabricate(:full_access_token_as_admin)
          delete_with_token "/api/v1/registers/#{register.id}", access_token.token
          expect(response).to have_http_status(204)
        end
      end


      describe "relationships" do
        it "gets the related comments for the #{mode} register only with token" do
          access_token = Fabricate(:simple_access_token)
          register     = Fabricate("#{mode}_register_with_two_comments_readable_by_world")
          user         = Fabricate(:user)
          comments     = register.comment_threads

          get_without_token "/api/v1/registers/#{register.id}/comments"
          expect(response).to have_http_status(401)
          get_with_token "/api/v1/registers/#{register.id}/comments", access_token.token
          expect(response).to have_http_status(200)
          comments.each do |comment|
            expect(json["data"].find{ |c| c["id"] == comment.id }["attributes"]["body"]).to eq(comment.body)
          end
        end

        xit "gets the related scores for #{mode} Register" do
          group     = Fabricate(:group)
          register  = Fabricate("#{mode}_register_readable_by_world", group: group)
          interval_information  = register.group.set_score_interval("day", Time.current.to_i)
          5.times do
            Score.create(
              mode: "autarchy",
              interval: interval_information[0],
              interval_beginning: interval_information[1],
              interval_end: interval_information[2],
              value: (rand * 10).to_i,
              scoreable_type: "Register::#{mode.camelize}",
              scoreable_id: register.id
            )
          end

          get_without_token "/api/v1/registers/#{register.id}/scores"
          expect(response).to have_http_status(200)
          expect(json["data"].size).to eq(5)
        end

        xit "paginates scores" do
          group     = Fabricate(:group)
          register  = Fabricate("#{mode}_register_readable_by_world", group: group)
          interval_information  = register.group.set_score_interval("day", Time.current.to_i)
          page_overload.times do
            Score.create(
              mode: "autarchy",
              interval: interval_information[0],
              interval_beginning: interval_information[1],
              interval_end: interval_information[2],
              value: (rand * 10).to_i,
              scoreable_type: "Register",
              scoreable_id: register.id
            )
          end
          get_without_token "/api/v1/registers/#{register.id}/scores"
          expect(response).to have_http_status(200)
          expect(json["meta"]["total_pages"]).to eq(2)

          get_without_token "/api/v1/registers/#{register.id}/scores", {per_page: 200}
          expect(response).to have_http_status(422)
        end


        it "paginates comments" do
          access_token    = Fabricate(:simple_access_token)
          register        = Fabricate("#{mode}_register_readable_by_world")
          user            = Fabricate(:user)
          comment_params  = {
            commentable_id:     register.id,
            commentable_type:   "Register::Base",
            user_id:            user.id,
            parent_id:          "",
          }
          comment = Fabricate(:comment, comment_params)
          page_overload.times do
            comment_params[:parent_id] = comment.id
            comment = Fabricate(:comment, comment_params)
          end
          get_with_token "/api/v1/registers/#{register.id}/comments", access_token.token

          expect(response).to have_http_status(200)
          expect(json["meta"]["total_pages"]).to eq(2)


          get_with_token "/api/v1/registers/#{register.id}/comments", {per_page: 200}, access_token.token
          expect(response).to have_http_status(422)
        end


        it "gets the related managers for the register only with token" do
          access_token    = Fabricate(:simple_access_token)
          register  = Fabricate("#{mode}_register_with_manager", readable: "world")
          manager         = register.managers.first
          get_without_token "/api/v1/registers/#{register.id}/managers"
          expect(response).to have_http_status(401)

          get_with_token "/api/v1/registers/#{register.id}/managers", access_token.token
          expect(response).to have_http_status(200)
          expect(json["data"].size).to eq(0)

          user            = User.find(access_token.resource_owner_id)
          user.add_role(:manager, register)
          get_with_token "/api/v1/registers/#{register.id}/managers", access_token.token
          expect(response).to have_http_status(200)
          expect(json["data"].size).to eq(1)
          expect(json["data"].collect {|d| d["id"]})
            .to match_array([user.id])

          manager_ids = register.managers.collect(&:id)
          ["world", "community", "friends"].each do |readable|
            manager.profile.update! readable: readable
            manager.friends << user if readable == "friends"
            get_with_token "/api/v1/registers/#{register.id}/managers", access_token.token
            expect(response).to have_http_status(200)
            expect(json["data"].size).to eq(2)
            expect(json["data"].collect {|d| d["id"]}).to match_array(manager_ids)
          end

          access_token    = Fabricate(:full_access_token_as_admin)
          get_with_token "/api/v1/registers/#{register.id}/managers", access_token.token
          expect(response).to have_http_status(200)
          expect(json["data"].size).to eq(2)
          expect(json["data"].collect {|d| d["id"]}).to match_array(manager_ids)
        end

        it "paginates managers" do
          access_token    = Fabricate(:simple_access_token)
          register  = Fabricate("#{mode}_register_readable_by_world")
          page_overload.times do
            user = Fabricate(:user)
            user.profile.update! readable: "world"
            user.add_role(:manager, register)
          end
          page_overload.times do
            user = Fabricate(:user)
            user.add_role(:manager, register)
          end
          get_with_token "/api/v1/registers/#{register.id}/managers", access_token.token
          expect(response).to have_http_status(200)
          expect(json["meta"]["total_pages"]).to eq(2)

          access_token    = Fabricate(:full_access_token_as_admin)
          get_with_token "/api/v1/registers/#{register.id}/managers", access_token.token
          expect(response).to have_http_status(200)
          expect(json["meta"]["total_pages"]).to eq(3)

          get_with_token "/api/v1/registers/#{register.id}/managers", {per_page: 200}, access_token.token
          expect(response).to have_http_status(422)
        end

        it "does not add/repalce/delete register manager or member without token" do
          register  = Fabricate("#{mode}_register_readable_by_world")
          user            = Fabricate(:user)
          params = {
            data: { id: user.id }
          }

          post_without_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json
          expect(response).to have_http_status(401)
          patch_without_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json
          expect(response).to have_http_status(401)
          delete_without_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json
          expect(response).to have_http_status(401)
          post_without_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json
          expect(response).to have_http_status(401)
          delete_without_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json
          expect(response).to have_http_status(401)
        end

        it "adds register manager only with manager or admin with full access token" do
          register  = Fabricate("#{mode}_register_readable_by_world")
          user1           = Fabricate(:user)
          user2           = Fabricate(:user)
          admin_token     = Fabricate(:full_access_token_as_admin)
          manager_token   = Fabricate(:full_access_token)
          manager         = User.find(manager_token.resource_owner_id)
          manager.add_role(:manager, register)
          member_token    = Fabricate(:full_access_token)
          member          = User.find(member_token.resource_owner_id)
          member.add_role(:member, register)
          params = {
            data: { id: user1.id }
          }

          post_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, member_token.token
          expect(response).to have_http_status(403)
          post_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, manager_token.token
          expect(response).to have_http_status(204)

          get_with_token "/api/v1/registers/#{register.id}/relationships/managers", admin_token.token
          expect(json["data"].size).to eq(2)
          params[:data][:id] = user2.id
          post_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, admin_token.token
          expect(response).to have_http_status(204)

          get_with_token "/api/v1/registers/#{register.id}/relationships/managers", admin_token.token
          expect(json["data"].size).to eq(3)
        end

        xit "creates activity when adding register manager" do
          user            = Fabricate(:user)
          admin_token     = Fabricate(:full_access_token_as_admin)
          admin           = User.find(admin_token.resource_owner_id)
          register  = Fabricate(:input_register)
          params = {
            data: { id: user.id }
          }

          post_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, admin_token.token
          activities      = PublicActivity::Activity.where({ owner_type: "User", owner_id: admin.id })
          expect(activities.first.key).to eq("user.appointed_register_manager")
        end


        it "replaces register managers" do
          register  = Fabricate("#{mode}_register_readable_by_world")
          user            = Fabricate(:user)
          simple_token    = Fabricate(:simple_access_token)
          simple_manager  = User.find(simple_token.resource_owner_id)
          manager_token   = Fabricate(:full_access_token)
          manager         = User.find(manager_token.resource_owner_id)
          user1           = Fabricate(:user)
          user2           = Fabricate(:user)
          simple_manager.add_role(:manager, register)
          manager.add_role(:manager, register)
          user1.add_role(:manager, register)
          user2.add_role(:manager, register)

          params = {
            data: [{ id: user.id }]
          }

          patch_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, simple_token.token
          expect(response).to have_http_status(403)

          # TODO manager should be able to read user which s/he adds as manager
          patch_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, manager_token.token
          expect(response).to have_http_status(200)

          # TODO add members here
          ["community", "world", "friends"].each do |readable|
            user.profile.update! readable: readable
            user.friends << manager if readable == "friends"

            get_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, manager_token.token
            expect(json["data"].size).to eq 1
            expect(json["data"].first["id"]).to eq user.id
          end
        end



        it "removes register manager only for current user or with full access token" do
          register  = Fabricate("#{mode}_register_readable_by_world")
          user            = Fabricate(:user)
          user.add_role(:manager, register)
          admin_token     = Fabricate(:full_access_token_as_admin)
          simple_token   = Fabricate(:simple_access_token)
          simple_manager = User.find(simple_token.resource_owner_id)
          simple_manager.add_role(:manager, register)
          manager_token   = Fabricate(:full_access_token)
          manager         = User.find(manager_token.resource_owner_id)
          manager.add_role(:manager, register)
          member_token    = Fabricate(:full_access_token)
          member          = User.find(member_token.resource_owner_id)
          member.add_role(:member, register)
          params = {
            data: { id: user.id }
          }

          get_with_token "/api/v1/registers/#{register.id}/managers", admin_token.token
          expect(json["data"].size).to eq(3)
          delete_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, member_token.token
          expect(response).to have_http_status(403)
          delete_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, simple_token.token
          expect(response).to have_http_status(403)
          delete_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, admin_token.token
          expect(response).to have_http_status(204)
          get_with_token "/api/v1/registers/#{register.id}/relationships/managers", admin_token.token
          expect(json["data"].size).to eq(2)
          params[:data][:id] = manager.id
          delete_with_token "/api/v1/registers/#{register.id}/relationships/managers", params.to_json, manager_token.token
          expect(response).to have_http_status(204)
          get_with_token "/api/v1/registers/#{register.id}/relationships/managers", admin_token.token
          expect(json["data"].size).to eq(1)
        end

        it "adds register member with member, manager or manager token" do
          register  = Fabricate("#{mode}_register_readable_by_world")
          user1           = Fabricate(:user)
          user2           = Fabricate(:user)
          user3           = Fabricate(:user)
          admin_token     = Fabricate(:full_access_token_as_admin)
          manager_token   = Fabricate(:full_access_token)
          manager         = User.find(manager_token.resource_owner_id)
          manager.add_role(:manager, register)
          member_token    = Fabricate(:full_access_token)
          member          = User.find(member_token.resource_owner_id)
          member.add_role(:member, register)
          params = {
            data: { id: user1.id }
          }

          post_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, member_token.token
          expect(response).to have_http_status(204)

          get_with_token "/api/v1/registers/#{register.id}/relationships/members", admin_token.token
          expect(json["data"].size).to eq(2)
          params[:data][:id] = user2.id
          post_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, manager_token.token
          expect(response).to have_http_status(204)

          get_with_token "/api/v1/registers/#{register.id}/relationships/members", admin_token.token
          expect(json["data"].size).to eq(3)
          params[:data][:id] = user3.id
          post_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, admin_token.token
          expect(response).to have_http_status(204)

          get_with_token "/api/v1/registers/#{register.id}/relationships/members", admin_token.token
          expect(json["data"].size).to eq(4)
        end

        xit "creates activity when adding register member" do
          user            = Fabricate(:user)
          admin_token     = Fabricate(:full_access_token_as_admin)
          register  = Fabricate(:input_register)
          params = {
            data: { id: user.id }
          }

          post_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, admin_token.token
          activities      = PublicActivity::Activity.where({ owner_type: "User", owner_id: user.id })
          expect(activities.first.key).to eq("register_user_membership.create")
        end

        it "paginates members" do
          access_token    = Fabricate(:full_access_token_as_admin)
          register  = Fabricate("#{mode}_register_readable_by_world")
          page_overload.times do
            user = Fabricate(:user)
            user.add_role(:member, register)
          end
          get_with_token "/api/v1/registers/#{register.id}/members", access_token.token
          expect(response).to have_http_status(200)
          expect(json["meta"]["total_pages"]).to eq(2)

          get_with_token "/api/v1/registers/#{register.id}/members", {per_page: 200}, access_token.token
          expect(response).to have_http_status(422)
        end


        it "replaces register members" do
          register        = Fabricate("#{mode}_register_readable_by_world")
          user            = Fabricate(:user)
          simple_token    = Fabricate(:simple_access_token)
          simple_member   = User.find(simple_token.resource_owner_id)
          manager_token   = Fabricate(:full_access_token)
          manager         = User.find(manager_token.resource_owner_id)
          user1           = Fabricate(:user)
          user2           = Fabricate(:user)
          manager.add_role(:manager, register)
          simple_member.add_role(:member, register)
          user1.add_role(:member, register)
          user2.add_role(:member, register)
          user.profile.update!(readable: "world")

          params = {
            data: [{ id: user.id }]
          }

          patch_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, simple_token.token
          expect(response).to have_http_status(403)
          patch_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, manager_token.token
          expect(response).to have_http_status(200)

          get_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, simple_token.token
          expect(json["data"].size).to eq 1
          expect(json["data"].first["id"]).to eq user.id
        end


        it "removes register member only for current user, manager or with full token" do
          register  = Fabricate("#{mode}_register_readable_by_world")
          user1           = Fabricate(:user)
          user1.add_role(:member, register)
          user2           = Fabricate(:user)
          user2.add_role(:member, register)
          admin_token     = Fabricate(:full_access_token_as_admin)
          manager_token   = Fabricate(:full_access_token)
          manager         = User.find(manager_token.resource_owner_id)
          manager.add_role(:manager, register)
          member_token    = Fabricate(:full_access_token)
          member          = User.find(member_token.resource_owner_id)
          member.add_role(:member, register)
          params = {
            data: { id: user1.id }
          }

          get_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, admin_token.token
          expect(json["data"].size).to eq(3)
          delete_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, member_token.token
          expect(response).to have_http_status(403)

          params[:data][:id] = member.id
          delete_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, member_token.token
          expect(response).to have_http_status(200)
          get_with_token "/api/v1/registers/#{register.id}/relationships/members", admin_token.token
          expect(json["data"].size).to eq(2)

          params[:data][:id] = user1.id
          delete_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, manager_token.token
          expect(response).to have_http_status(200)
          get_with_token "/api/v1/registers/#{register.id}/relationships/members", admin_token.token
          expect(json["data"].size).to eq(1)

          params[:data][:id] = user2.id
          delete_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, admin_token.token
          expect(response).to have_http_status(200)
          get_with_token "/api/v1/registers/#{register.id}/relationships/members", admin_token.token
          expect(json["data"].size).to eq(0)
        end

        xit "creates activity when removing register member" do
          user            = Fabricate(:user)
          admin_token     = Fabricate(:full_access_token_as_admin)
          register  = Fabricate(:input_register)
          params = {
            data: { id: user.id }
          }

          delete_with_token "/api/v1/registers/#{register.id}/relationships/members", params.to_json, admin_token.token
          activities      = PublicActivity::Activity.where({ owner_type: "User", owner_id: user.id })
          expect(activities.first.key).to eq("register_user_membership.cancel")
        end


        xit "gets address of the register only with token" do
          access_token    = Fabricate(:simple_access_token)
          register        = Fabricate(:register_urbanstr88, readable: "world")
          address         = register.address
          user            = User.find(access_token.resource_owner_id)

          get_without_token "/api/v1/registers/#{register.id}/address"
          expect(response).to have_http_status(401)

          get_with_token "/api/v1/registers/#{register.id}/address", access_token.token
          expect(response).to have_http_status(403)

          user.add_role(:manager, register)
          get_with_token "/api/v1/registers/#{register.id}/address", access_token.token
          expect(json["data"]["id"]).to eq(address.id)
          expect(response).to have_http_status(200)
        end



        it "gets only accessible profiles for the register" do
          register    = Fabricate("#{mode}_register_readable_by_world")
          access_token      = Fabricate(:access_token_with_friend)
          token_user        = User.find(access_token.resource_owner_id)
          token_user_friend = token_user.friends.first
          token_user_friend.profile.readable = "friends"
          token_user_friend.profile.save
          community_token   = Fabricate(:simple_access_token)
          community_user    = Fabricate(:user)
          community_user.profile.readable = "community"
          community_user.profile.save
          world_user        = Fabricate(:user)
          world_user.profile.readable = "world"
          world_user.profile.save
          token_user_friend.add_role(:member, register)
          community_user.add_role(:member, register)
          world_user.add_role(:member, register)

          get_without_token "/api/v1/registers/#{register.id}/members"
          expect(response).to have_http_status(200)
          expect(json["data"].size).to eq(1)
          get_with_token "/api/v1/registers/#{register.id}/members", access_token.token
          expect(response).to have_http_status(200)
          expect(json["data"].size).to eq(3)
          get_with_token "/api/v1/registers/#{register.id}/members", community_token.token
          expect(response).to have_http_status(200)
          expect(json["data"].size).to eq(2)
        end


        it 'gets meter for the register only by managers' do
          register      = Fabricate("#{mode}_register".to_sym, meter: Fabricate(:meter))
          access_token  = Fabricate(:simple_access_token)
          token_user    = User.find(access_token.resource_owner_id)
          wrong_token   = Fabricate(:simple_access_token)
          token_user.add_role(:manager, register)

          get_with_token "/api/v1/registers/#{register.id}/meter", access_token.token

          expect(response).to have_http_status(200)
          expect(json['data']['id']).to eq(register.meter.id)
          
          get_with_token "/api/v1/registers/#{register.id}/meter", wrong_token.token
          
          expect(response).to have_http_status(403)
        end
      end
    end

  end




  xit 'adds a register to meter with full access token' do
  end


end
