# The upgrade from Ruby 2.3.8 to 2.6.6 and their gems broke the encryption
# of the documents. This tests check if the encryption and decryption works while 
# upgrading the ruby version. Fix is in 9333bd3af63f40d7269c596456cb3301a671de1e
describe Security::SecureHashSerializer do
    let(:serializer) {Security::SecureHashSerializer.new}
    let(:sample_data) do 
        {
            data: "Encrypt this but dont be it too short.",
            data2:[1,2,3]
        }
    end

    let(:encrypted_ruby_2_6_6) do
        'b01zSExYdmhZbXBNakZMQm1xTWw1L0lhUENoeG5XU1FIdHppUG40ZkRiU3lIbjhkSkhBN2h1RVJQUC93UlQyN2hRcVF2QlVXdkQ0M0JsSDlwY1ArbFJIOVIvQkJ0WGtRNkI0MkpsMTBTS1gyWUlIVFdNOUEwYjM0dys0NUhsYVYtLU4rQit0c2NiRThORmpIMk45dkRHUmc9PQ==--e4e2e2effdf302cc31f061fb607f402a5300755d'
    end

    let(:encrypted_ruby_2_3_8) do
        'TUFPU0VzRVJwbWFVdWUwdVlNdVdhTEdsdVRZeCt0K1BWRCt2Sm9iUi9GcTFjNktFS3JpZXMvWHFMQWpYckhrTndnb1lTWXFydnVHVldOUnpET2ZHZ25mSFM2c1lCdmE5RnV5R3B5VWNEenRJNWJFN3craFFnNExtU0lpRUJqNVEtLXQzam40WkhuQ3ZQTzlROXJsTFpVYlE9PQ==--7016e263d22a085128beeb005e81e7a6d2e64842'
    end

    it 'encrypts sample_data and decrypts again and checks whether sample matches decrypted' do
        encrypted = serializer.dump(sample_data)
        decrypted = serializer.load(encrypted)

        expect(decrypted).to eq sample_data
    end

    ['encrypted_ruby_2_3_8', 'encrypted_ruby_2_6_6'].each do |c|
        it "loads data encrypted with #{c}" do
            actual = serializer.load(send(c))
            expect(actual).to eq sample_data
        end
    end
end