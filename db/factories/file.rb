FactoryGirl.define do
  factory :file, class: Hash do
    size 2048
    file do
      file = Tempfile.new('test.bin')
      file.write(Random.new.bytes(size))
      file.close
      file.path
    end
    mime 'application/octet-stream'
    sha256 ''

    after(:build) do |file, sha256|
      if sha256 == ''
        File.open('file', 'r') do |f|
          sha256d = Digest::SHA256.new
          sha256 = sha256d.hexdigest(f.read)
        end
      end
    end

    trait :png do
      file 'test.png'
      mime 'image/png'
      size 17787
      sha256 '49de6c289ace1f224ded6d813423a07a346debb0d5e662b4be8095b60af49a94'
    end

    trait :txt do
      file 'test.txt'
      mime 'text/plain'
      size 9
      sha256 'efd2c46f61d312c1fb880ffc0589759eff34403864f93d376c7c3b7d816528b5'
    end

    trait :pdf do
      file 'test.pdf'
      mime 'application/pdf'
      size 9602
      sha256 '0a1a44171994d640c3d4f75f919a05de519a13c26998e72ba2b242f0ef1e8b67'
    end

    initialize_with { attributes }
  end
end
