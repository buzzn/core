{
  actionmailer = {
    dependencies = ["actionpack" "actionview" "activejob" "mail" "rails-dom-testing"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18wwlj4f7jffv3vxm80d2z36nwza95l5xfcqc401hvvrls4xzhsy";
      type = "gem";
    };
    version = "4.2.11.1";
  };
  actionpack = {
    dependencies = ["actionview" "activesupport" "rack" "rack-test" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rmldsk3a4lwxk0lrp6x1nz1v1r2xmbm3300l4ghgfygv3grdwjh";
      type = "gem";
    };
    version = "4.2.11.1";
  };
  actionview = {
    dependencies = ["activesupport" "builder" "erubis" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0x7vjn8q6blzyf7j3kwg0ciy7vnfh28bjdkd1mp9k4ghp9jn0g9p";
      type = "gem";
    };
    version = "4.2.11.1";
  };
  activejob = {
    dependencies = ["activesupport" "globalid"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jy1c1r6syjqpa0sh9f1p4iaxzvp6qg4n6zs774j9z27q7h407mj";
      type = "gem";
    };
    version = "4.2.11.1";
  };
  activemodel = {
    dependencies = ["activesupport" "builder"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1c1x0rd6wnk1f0gsmxs6x3gx7yf6fs9qqkdv7r4hlbcdd849in33";
      type = "gem";
    };
    version = "4.2.11.1";
  };
  activerecord = {
    dependencies = ["activemodel" "activesupport" "arel"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07ixiwi0zzs9skqarvpfamsnay7npfswymrn28ngxaf8hi279q5p";
      type = "gem";
    };
    version = "4.2.11.1";
  };
  activesupport = {
    dependencies = ["i18n" "minitest" "thread_safe" "tzinfo"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vbq7a805bfvyik2q3kl9s3r418f5qzvysqbz2cwy4hr7m2q4ir6";
      type = "gem";
    };
    version = "4.2.11.1";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fvchp2rhp2rmigx7qglf69xvjqvzq7x0g49naliw29r2bz656sy";
      type = "gem";
    };
    version = "2.7.0";
  };
  arel = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nfcrdiys6q6ylxiblky9jyssrw2xj96fmxmal7f4f0jj3417vj4";
      type = "gem";
    };
    version = "6.0.4";
  };
  ast = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "184ssy3w93nkajlz2c70ifm79jp3j737294kbc5fjw69v1w0n9x7";
      type = "gem";
    };
    version = "2.4.0";
  };
  awesome_print = {
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14arh1ixfsd6j5md0agyzvksm5svfkvchb90fp32nn7y3avcmc2h";
      type = "gem";
    };
    version = "1.8.0";
  };
  bcrypt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ai0m15jg3n0b22mimk09ppnga316dc7dyvz06w8rrqh5gy1lslp";
      type = "gem";
    };
    version = "3.1.13";
  };
  binding_of_caller = {
    dependencies = ["debug_inspector"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05syqlks7463zsy1jdfbbdravdhj9hpj5pv2m74blqpv8bq4vv5g";
      type = "gem";
    };
    version = "0.8.0";
  };
  brakeman = {
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xy28pq4x1i7xns5af9k8fx35sqffz2lg94fgbsi9zhi877b7srg";
      type = "gem";
    };
    version = "4.8.0";
  };
  builder = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "045wzckxpwcqzrjr353cxnyaxgf0qg22jh00dcx7z38cys5g1jlr";
      type = "gem";
    };
    version = "3.2.4";
  };
  byebug = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18a9wlwvwxi86nldj56jbk6pwx3rd8l5xi6p8ap24p169h9m8wc4";
      type = "gem";
    };
    version = "11.1.1";
  };
  carrierwave = {
    dependencies = ["activemodel" "activesupport" "mime-types"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10rz94kajilffp83sb767lr62b5f8l4jzqq80cr92wqxdgbszdks";
      type = "gem";
    };
    version = "1.3.1";
  };
  clockwork = {
    dependencies = ["activesupport" "tzinfo"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kvdhl7qi6mx4mf3difn8lh8shhigmrdfrqnff3k07ci5ng4wxhj";
      type = "gem";
    };
    version = "2.0.4";
  };
  coderay = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15vav4bhcc2x3jmi3izb11l4d9f3xv8hp2fszb7iqmpsccv1pz4y";
      type = "gem";
    };
    version = "1.1.2";
  };
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "094387x4yasb797mv07cs3g6f08y56virc2rjcpb1k79rzaj3nhl";
      type = "gem";
    };
    version = "1.1.6";
  };
  concurrent-ruby-ext = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0x1i03r3vbwa7wfhhz1dhgcl8kx4vvwys6qrfp5qzy9yvbwrim16";
      type = "gem";
    };
    version = "1.1.6";
  };
  connection_pool = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lflx29mlznf1hn0nihkgllzbj8xp5qasn8j7h838465pi399k68";
      type = "gem";
    };
    version = "2.2.2";
  };
  countries = {
    dependencies = ["i18n_data" "sixarm_ruby_unaccent" "unicode_utils"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01plfwixvfw5z3jdr5b792njf55vqmj35drmlvqmvkq6ha4q3nvq";
      type = "gem";
    };
    version = "3.0.1";
  };
  crass = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
    version = "1.0.6";
  };
  debug_inspector = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vxr0xa1mfbkfcrn71n7c4f2dj7la5hvphn904vh20j3x4j5lrx0";
      type = "gem";
    };
    version = "0.0.3";
  };
  diff-lcs = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18w22bjz424gzafv6nzv98h0aqkwz3d9xhm7cbr1wfbyas8zayza";
      type = "gem";
    };
    version = "1.3";
  };
  dotenv = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17hkd62ig9b0czv192kqdfq7gw0a8hgq07yclri6myc8y5lmfin5";
      type = "gem";
    };
    version = "2.7.5";
  };
  dry-auto_inject = {
    dependencies = ["dry-container"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10c90qyq07gbmwr0jjdsc335py2ji90vk132i5ng6lbcd4hs46hm";
      type = "gem";
    };
    version = "0.7.0";
  };
  dry-configurable = {
    dependencies = ["concurrent-ruby" "dry-core" "dry-equalizer"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kj9vzfmgy00nmi6b8m9bqfdnz2ay31v1dgmx0ksplx77xlh7c4b";
      type = "gem";
    };
    version = "0.11.4";
  };
  dry-container = {
    dependencies = ["concurrent-ruby" "dry-configurable"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1npnhs3x2xcwwijpys5c8rpcvymrlab0y8806nr4h425ld5q4wd0";
      type = "gem";
    };
    version = "0.7.2";
  };
  dry-core = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k9ff2sr4ymiwzg4mchzv66mn6rdsgjlinm6s4x5x91yhd0h4vpk";
      type = "gem";
    };
    version = "0.4.9";
  };
  dry-dependency-injection = {
    dependencies = ["concurrent-ruby" "dry-container" "dry-core"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1br90digb45rmb66swq278csfjwxpav0c28g85zx7ra67ah1vvn5";
      type = "gem";
    };
    version = "0.2.0";
  };
  dry-equalizer = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rsqpk0gjja6j6pjm0whx2px06cxr3h197vrwxp6k042p52r4v46";
      type = "gem";
    };
    version = "0.3.0";
  };
  dry-events = {
    dependencies = ["concurrent-ruby" "dry-core" "dry-equalizer"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cyspwnblzci3g7k3y4v70mwi9l19wl5ldx966nlv1xj21wmxkaf";
      type = "gem";
    };
    version = "0.2.0";
  };
  dry-initializer = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gpxx4mvx6v3nkibh31ai9j5r1gi8v8mfb37g4vmgr27dyrf70yy";
      type = "gem";
    };
    version = "3.0.3";
  };
  dry-logic = {
    dependencies = ["dry-container" "dry-core" "dry-equalizer"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1r6z223dz1kwkgxwszvcik5glg3rxy9d7c4jrb62iz07g94hlwjh";
      type = "gem";
    };
    version = "0.4.2";
  };
  dry-matcher = {
    dependencies = ["dry-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fv18zfw0qq8yqdixcck9c79vcrskyaxr953djk0q5kasr0z0v3c";
      type = "gem";
    };
    version = "0.8.3";
  };
  dry-monads = {
    dependencies = ["concurrent-ruby" "dry-core" "dry-equalizer"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "151czj5882x38fnxgqwc7i9gnvh5yv7z823mzx1yv1s6hl39av1g";
      type = "gem";
    };
    version = "1.3.5";
  };
  dry-struct = {
    dependencies = ["dry-core" "dry-equalizer" "dry-types" "ice_nine"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dh42laaffz9cdcir8rxxp64dn3zjj32g8xyl956wmsk91cb8gqp";
      type = "gem";
    };
    version = "0.4.0";
  };
  dry-transaction = {
    dependencies = ["dry-container" "dry-events" "dry-matcher" "dry-monads"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d7q2j6516zfjqjh3464pv7fzqgx5w4q1gx8piqwxbahw69j7s88";
      type = "gem";
    };
    version = "0.13.0";
  };
  dry-types = {
    dependencies = ["concurrent-ruby" "dry-configurable" "dry-container" "dry-core" "dry-equalizer" "dry-logic" "inflecto"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wjwyavb0zhy3m26915jkdp5sm37i27s88z3jrmriqbbibbi41g4";
      type = "gem";
    };
    version = "0.12.3";
  };
  dry-validation = {
    dependencies = ["concurrent-ruby" "dry-configurable" "dry-core" "dry-equalizer" "dry-logic" "dry-types"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n5h771d8cpaz83a5whmsch5a0jc49nckhzslkl6f0jwkm0amxvk";
      type = "gem";
    };
    version = "0.11.2";
  };
  em-websocket = {
    dependencies = ["eventmachine" "http_parser.rb"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bsw8vjz0z267j40nhbmrvfz7dvacq4p0pagvyp17jif6mj6v7n3";
      type = "gem";
    };
    version = "0.5.1";
  };
  erubis = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fj827xqjs91yqsydf0zmfyw9p4l2jz5yikg3mppz6d7fi8kyrb3";
      type = "gem";
    };
    version = "2.7.0";
  };
  eventmachine = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wh9aqb0skz80fhfn66lbpr4f86ya2z5rx6gm5xlfhd05bj1ch4r";
      type = "gem";
    };
    version = "1.2.7";
  };
  excon = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zvphy60fwycl6z2h7dpsy9lgyfrh27fj16987p7bl1n4xlqkvmw";
      type = "gem";
    };
    version = "0.73.0";
  };
  factory_girl = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11aba280hy0xihpnyn2l1jzrgnnkq95nd7r157j99dskbibmj43d";
      type = "gem";
    };
    version = "4.9.0";
  };
  faraday = {
    dependencies = ["multipart-post"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11yn7mhi4rl24brs2qfwysas14csjf1zmb835cfklqz5ka032xp6";
      type = "gem";
    };
    version = "1.0.0";
  };
  ffaker = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0l95jj17k8nkgwkzklcyizbi9l8ly3fgb6ck3qimhvgvzkgbn3pz";
      type = "gem";
    };
    version = "2.14.0";
  };
  ffi = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10lfhahnnc91v63xpvk65apn61pib086zha3z5sp1xk9acfx12h4";
      type = "gem";
    };
    version = "1.12.2";
  };
  fog-aws = {
    dependencies = ["fog-core" "fog-json" "fog-xml" "ipaddress"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "086kyvdhf1k8nk7f4gmybjc3k0m88f9pw99frddcy1w96pj5kyg4";
      type = "gem";
    };
    version = "3.5.2";
  };
  fog-core = {
    dependencies = ["builder" "excon" "formatador" "mime-types"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s1jxlrbq4jhwkiy5gq429v87m1l602b2gppw0ikbax7rnv30s9x";
      type = "gem";
    };
    version = "2.2.0";
  };
  fog-json = {
    dependencies = ["fog-core" "multi_json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zj8llzc119zafbmfa4ai3z5s7c4vp9akfs0f9l2piyvcarmlkyx";
      type = "gem";
    };
    version = "1.2.0";
  };
  fog-local = {
    dependencies = ["fog-core"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ba4lln35nryi6dcbz68vxg9ml6v8cc8s8c82f7syfd84bz76x21";
      type = "gem";
    };
    version = "0.6.0";
  };
  fog-xml = {
    dependencies = ["fog-core" "nokogiri"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "043lwdw2wsi6d55ifk0w3izi5l1d1h0alwyr3fixic7b94kc812n";
      type = "gem";
    };
    version = "0.1.3";
  };
  formatador = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gc26phrwlmlqrmz4bagq1wd5b7g64avpx0ghxr9xdxcvmlii0l0";
      type = "gem";
    };
    version = "0.2.5";
  };
  globalid = {
    dependencies = ["activesupport"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zkxndvck72bfw235bd9nl2ii0lvs5z88q14706cmn702ww2mxv1";
      type = "gem";
    };
    version = "0.4.2";
  };
  guard = {
    dependencies = ["formatador" "listen" "lumberjack" "nenv" "notiffany" "pry" "shellany" "thor"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zw9zzf6ha9brj5qxn5fyw61gjcrw872d1qx11hd08dqrnsd4nx3";
      type = "gem";
    };
    version = "2.16.1";
  };
  guard-brakeman = {
    dependencies = ["brakeman" "guard" "guard-compat"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gv0049r61kf1v83l6blg7ccli0r3z6ifgq8kkxszi2a0xg177i2";
      type = "gem";
    };
    version = "0.8.6";
  };
  guard-bundler = {
    dependencies = ["guard" "guard-compat"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lji8f8w7y4prmpr2lqmlljvkqgkgnlsiwqgwvq7b1y3sxlsvy62";
      type = "gem";
    };
    version = "2.2.1";
  };
  guard-compat = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zj6sr1k8w59mmi27rsii0v8xyy2rnsi09nqvwpgj1q10yq1mlis";
      type = "gem";
    };
    version = "1.2.1";
  };
  guard-livereload = {
    dependencies = ["em-websocket" "guard" "guard-compat" "multi_json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yd74gdbbv2yz2caqwpsavzw8d5fd5y446wp8rdjw8wan0yd6k8j";
      type = "gem";
    };
    version = "2.5.2";
  };
  guard-rspec = {
    dependencies = ["guard" "guard-compat" "rspec"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jkm5xp90gm4c5s51pmf92i9hc10gslwwic6mvk72g0yplya0yx4";
      type = "gem";
    };
    version = "4.7.3";
  };
  "http_parser.rb" = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15nidriy0v5yqfjsgsra51wmknxci2n2grliz78sf9pga3n0l7gi";
      type = "gem";
    };
    version = "0.6.0";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "038qvz7kd3cfxk8bvagqhakx68pfbnmghpdkx7573wbf0maqp9a3";
      type = "gem";
    };
    version = "0.9.5";
  };
  i18n_data = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "084b7hcb02ii2pmvzi3s5kpzibhaxjd23i4vy9p56jqykk3am8s6";
      type = "gem";
    };
    version = "0.10.0";
  };
  iban-tools = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lz6idka39qbh1vv8sp8kd5rzdmxi5452lx2ank63958jiww52by";
      type = "gem";
    };
    version = "1.1.0";
  };
  ice_nine = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nv35qg1rps9fsis28hz2cq2fx1i96795f91q4nmkm934xynll2x";
      type = "gem";
    };
    version = "0.11.2";
  };
  inflecto = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "085l5axmvqw59mw5jg454a3m3gr67ckq9405a075isdsn7bm3sp4";
      type = "gem";
    };
    version = "0.0.2";
  };
  interception = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01vrkn28psdx1ysh5js3hn17nfp1nvvv46wc1pwqsakm6vb1hf55";
      type = "gem";
    };
    version = "0.5";
  };
  ipaddress = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x86s0s11w202j6ka40jbmywkrx8fhq8xiy8mwvnkhllj57hqr45";
      type = "gem";
    };
    version = "0.8.3";
  };
  its-it = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h7zqx40yv42a50f1s8qj59rf0w9lkf727ff1ysj3a3fvzrsn7gk";
      type = "gem";
    };
    version = "1.3.0";
  };
  jaro_winkler = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1y8l6k34svmdyqxya3iahpwbpvmn3fswhwsvrz0nk1wyb8yfihsh";
      type = "gem";
    };
    version = "1.5.4";
  };
  jbuilder = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03adzsc2hfd0lvprm45s52bkxpnpnw8r9prcx8zx1aw2a8lzp9r7";
      type = "gem";
    };
    version = "2.9.1";
  };
  jwt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01zg1vp3lyl3flyjdkrcc93ghf833qgfgh2p1biqfhkzz11r129c";
      type = "gem";
    };
    version = "2.2.1";
  };
  key_struct = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ranj2ig7y0pxz10873wnfsz73mwh53h40w6803rqamz3hgvgbyc";
      type = "gem";
    };
    version = "0.4.2";
  };
  leafy = {
    dependencies = ["concurrent-ruby"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08as8i5b6qwl8sgayfpg044x8b2dkrqic71b9dlb9l2zpza3k9pz";
      type = "gem";
    };
    version = "0.1.0";
  };
  listen = {
    dependencies = ["rb-fsevent" "rb-inotify"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1w923wmdi3gyiky0asqdw5dnh3gcjs2xyn82ajvjfjwh6sn0clgi";
      type = "gem";
    };
    version = "3.2.1";
  };
  loofah = {
    dependencies = ["crass" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g7ps9m3s14cajhxrfgbzahv9i3gy47s4hqrv3mpybpj5cyr0srn";
      type = "gem";
    };
    version = "2.4.0";
  };
  lumberjack = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1m9ajfrs5ys3dp2glwbmyzfpd7qyz7dz49gz78is1yra0jawkm6d";
      type = "gem";
    };
    version = "1.2.4";
  };
  magic = {
    dependencies = ["ffi"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18vkdq2748wxg0kr923fbhx92wikh2dwv2hp8xind57qs7gn26pr";
      type = "gem";
    };
    version = "0.2.9";
  };
  mail = {
    dependencies = ["mini_mime"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00wwz6ys0502dpk8xprwcqfwyf3hmnx6lgxaiq6vj43mkx43sapc";
      type = "gem";
    };
    version = "2.7.1";
  };
  method_source = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pnyh44qycnf9mzi1j6fywd5fkskv3x7nmsqrrws0rjn5dd4ayfp";
      type = "gem";
    };
    version = "1.0.0";
  };
  mime-types = {
    dependencies = ["mime-types-data"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zj12l9qk62anvk9bjvandpa6vy4xslil15wl6wlivyf51z773vh";
      type = "gem";
    };
    version = "3.3.1";
  };
  mime-types-data = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18x61fc36951vw7f74gq8cyybdpxvyg5d0azvqhrs82ddw3v16xh";
      type = "gem";
    };
    version = "3.2019.1009";
  };
  mini_magick = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lpq12z70n10c1qshcddd5nib2pkcbkwzvmiqqzj60l01k3x4fg9";
      type = "gem";
    };
    version = "4.10.1";
  };
  mini_mime = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1axm0rxyx3ss93wbmfkm78a6x03l8y4qy60rhkkiq0aza0vwq3ha";
      type = "gem";
    };
    version = "1.0.2";
  };
  mini_portile2 = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15zplpfw3knqifj9bpf604rb3wc1vhq6363pd6lvhayng8wql5vy";
      type = "gem";
    };
    version = "2.4.0";
  };
  minitest = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g73x65hmjph8dg1h3rkzfg7ys3ffxm35hj35grw75fixmq53qyz";
      type = "gem";
    };
    version = "5.14.0";
  };
  modware = {
    dependencies = ["key_struct"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1i4v25qz6g3z5vbbm0qaqa9lbqyfgcsahy2hpinx3l3j5c1pbsjn";
      type = "gem";
    };
    version = "0.1.3";
  };
  multi_json = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xy54mjf7xg41l8qrg1bqri75agdqmxap9z466fjismc1rn2jwfr";
      type = "gem";
    };
    version = "1.14.1";
  };
  multipart-post = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zgw9zlwh2a6i1yvhhc4a84ry1hv824d6g2iw2chs3k5aylpmpfj";
      type = "gem";
    };
    version = "2.1.1";
  };
  nenv = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0r97jzknll9bhd8yyg2bngnnkj8rjhal667n7d32h8h7ny7nvpnr";
      type = "gem";
    };
    version = "0.3.0";
  };
  newrelic_rpm = {
    groups = ["production" "staging"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mil1cslz3q2xysb1bpsyaz58c0mq400nfbrjy65y5fx0jvjdyiy";
      type = "gem";
    };
    version = "6.9.0.363";
  };
  nio4r = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gnmvbryr521r135yz5bv8354m7xn6miiapfgpg1bnwsvxz8xj6c";
      type = "gem";
    };
    version = "2.5.2";
  };
  nokogiri = {
    dependencies = ["mini_portile2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12j76d0bp608932xkzmfi638c7aqah57l437q8494znzbj610qnm";
      type = "gem";
    };
    version = "1.10.9";
  };
  notiffany = {
    dependencies = ["nenv" "shellany"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f47h3bmg1apr4x51szqfv3rh2vq58z3grh4w02cp3bzbdh6jxnk";
      type = "gem";
    };
    version = "0.1.3";
  };
  oauth = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zszdg8q1b135z7l7crjj234k4j0m347hywp5kj6zsq7q78pw09y";
      type = "gem";
    };
    version = "0.5.4";
  };
  oj = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16qqi1dgc3l5j2xwsl9cigz9hjasvv3vndd6yim7dz7fs21v59sx";
      type = "gem";
    };
    version = "3.10.5";
  };
  parallel = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12jijkap4akzdv11lm08dglsc8jmc87xcgq6947i1s3qb69f4zn2";
      type = "gem";
    };
    version = "1.19.1";
  };
  parser = {
    dependencies = ["ast"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0iirjc36irgwpfb58jdf9gli382cj893y9caqhxas8anpzzlikgc";
      type = "gem";
    };
    version = "2.7.0.5";
  };
  pg = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03xcgwjs6faxis81jxf2plnlalg55dhhafqv3kvjxfr8ic7plpw5";
      type = "gem";
    };
    version = "0.20.0";
  };
  pgreset = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05429cb7a79gbqwzfzhxqppda88i5pgm13zw49l0aply49slgq0x";
      type = "gem";
    };
    version = "0.1.1";
  };
  pry = {
    dependencies = ["coderay" "method_source"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lgvnhnwgji1d30vpwlsydk2sabv5azigq9nlfjp0nc4f6wdkdvl";
      type = "gem";
    };
    version = "0.13.0";
  };
  pry-byebug = {
    dependencies = ["byebug" "pry"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "096y5vmzpyy4x9h4ky4cs4y7d19vdq9vbwwrqafbh5gagzwhifiv";
      type = "gem";
    };
    version = "3.9.0";
  };
  pry-rescue = {
    dependencies = ["interception" "pry"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cni4icgjpn17iyq23sxsvbi35m5ix74li95gw8i15kry6fn7rcb";
      type = "gem";
    };
    version = "1.5.0";
  };
  pry-stack_explorer = {
    dependencies = ["binding_of_caller" "pry"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0r95n0p279ycr2bcldbnws5cnkc6m1ylrssxynsp3vxy6cjd7524";
      type = "gem";
    };
    version = "0.4.9.3";
  };
  public_suffix = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1c6kq6s13idl2036b5lch8r7390f8w82cal8hcp4ml76fm2vdac7";
      type = "gem";
    };
    version = "4.0.3";
  };
  puma = {
    dependencies = ["nio4r"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xwba5n3i17x8anfhk8w2wv5qzk8xlm6r7p2dj9v4lffb9in694f";
      type = "gem";
    };
    version = "4.3.3";
  };
  rack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wr1f3g9rc9i8svfxa9cijajl1661d817s56b2w7rd572zwn0zi0";
      type = "gem";
    };
    version = "1.6.13";
  };
  rack-cors = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07dppmm1ah1gs31sb5byrkkady9vqzwjmpd92c8425nc6yzwknik";
      type = "gem";
    };
    version = "1.0.6";
  };
  rack-protection = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zyj97bfr1shfgwk4ddmdbw0mdkm4qdyh9s1hl0k7accf3kxx1yi";
      type = "gem";
    };
    version = "2.0.8.1";
  };
  rack-test = {
    dependencies = ["rack"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h6x5jq24makgv2fq5qqgjlrk74dxfy62jif9blk43llw8ib2q7z";
      type = "gem";
    };
    version = "0.6.3";
  };
  rails = {
    dependencies = ["actionmailer" "actionpack" "actionview" "activejob" "activemodel" "activerecord" "activesupport" "railties" "sprockets-rails"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ywvis59dd3v8qapi9ix6743zgk07l21x1cd6nb1ddpahxhm7dml";
      type = "gem";
    };
    version = "4.2.11.1";
  };
  rails-deprecated_sanitizer = {
    dependencies = ["activesupport"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qxymchzdxww8bjsxj05kbf86hsmrjx40r41ksj0xsixr2gmhbbj";
      type = "gem";
    };
    version = "1.0.3";
  };
  rails-dom-testing = {
    dependencies = ["activesupport" "nokogiri" "rails-deprecated_sanitizer"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wssfqpn00byhvp2372p99mphkcj8qx6pf6646avwr9ifvq0q1x6";
      type = "gem";
    };
    version = "1.0.9";
  };
  rails-html-sanitizer = {
    dependencies = ["loofah"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gv7vr5d9g2xmgpjfq4nxsqr70r9pr042r9ycqqnfvw5cz9c7jwr";
      type = "gem";
    };
    version = "1.0.4";
  };
  rails_12factor = {
    dependencies = ["rails_serve_static_assets" "rails_stdout_logging"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x8gj0d3j3a789nkfrkj98icx00bannblz81z84j29k6k79qi6zf";
      type = "gem";
    };
    version = "0.0.3";
  };
  rails_serve_static_assets = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sc02fp9ad4qjfb9p450fz7rvck4all468kybkpi518qmxzg0fr0";
      type = "gem";
    };
    version = "0.0.5";
  };
  rails_stdout_logging = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x0l90vkrr5mjdrfgq1hz9pz4d28225n0x5mk6apa2n3kj3mhwg5";
      type = "gem";
    };
    version = "0.0.5";
  };
  railties = {
    dependencies = ["actionpack" "activesupport" "rake" "thor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bjf21z9maiiazc1if56nnh9xmgbkcqlpznv34f40a1hsvgk1d1m";
      type = "gem";
    };
    version = "4.2.11.1";
  };
  rainbow = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bb2fpjspydr6x0s8pn1pqkzmxszvkfapv0p4627mywl7ky4zkhk";
      type = "gem";
    };
    version = "3.0.0";
  };
  rake = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0w6qza25bq1s825faaglkx1k6d59aiyjjk3yw3ip5sb463mhhai9";
      type = "gem";
    };
    version = "13.0.1";
  };
  rb-fsevent = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lm1k7wpz69jx7jrc92w3ggczkjyjbfziq5mg62vjnxmzs383xx8";
      type = "gem";
    };
    version = "0.10.3";
  };
  rb-inotify = {
    dependencies = ["ffi"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jm76h8f8hji38z3ggf4bzi8vps6p7sagxn3ab57qc0xyga64005";
      type = "gem";
    };
    version = "0.10.1";
  };
  redis = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08v2y91q1pmv12g9zsvwj66w3s8j9d82yrmxgyv4y4gz380j3wyh";
      type = "gem";
    };
    version = "4.1.3";
  };
  remote_lock = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xk55hnzdi96r4y7x0agqi6kdrhwhshhj42lwyhiw17ar2pd0f4p";
      type = "gem";
    };
    version = "1.1.0";
  };
  rexml = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mkvkcw9fhpaizrhca0pdgjcrbns48rlz4g6lavl5gjjq3rk2sq3";
      type = "gem";
    };
    version = "3.2.4";
  };
  roda = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zmvc1580g6yav0q79w0yh5xxzsfynjl51nr41zs0g116spxiak8";
      type = "gem";
    };
    version = "3.30.0";
  };
  rodauth = {
    dependencies = ["roda" "sequel"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ywvffqwkijhd50gsg3hj877xskharvibf1mxk146kwim5isl78r";
      type = "gem";
    };
    version = "1.23.0";
  };
  rspec = {
    dependencies = ["rspec-core" "rspec-expectations" "rspec-mocks"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hzsig4pi9ybr0xl5540m1swiyxa74c8h09225y5sdh2rjkkg84h";
      type = "gem";
    };
    version = "3.9.0";
  };
  rspec-core = {
    dependencies = ["rspec-support"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qzc1wdjb1qnbimjl8i1q1r1z5hdv2lmcw7ysz7jawj4d1cvpqvd";
      type = "gem";
    };
    version = "3.9.1";
  };
  rspec-expectations = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fjbwvq7qaz6h3sh1bs9q2qiy4zwcrc8f7xwv82dx2bc09dmqzhd";
      type = "gem";
    };
    version = "3.9.1";
  };
  rspec-mocks = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19vmdqym1v2g1zbdnq37zwmyj87y9yc9ijwc8js55igvbb9hx0mr";
      type = "gem";
    };
    version = "3.9.1";
  };
  rspec-support = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zwpyq1na23pvgacpxs2v9nwfbjbw6x3arca5j3l1xagigqmzhc3";
      type = "gem";
    };
    version = "3.9.2";
  };
  rspec_nested_transactions = {
    dependencies = ["rspec"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b63vy9871kqifzm8f5dcqf78cgx321bwri4p9wiappxq9ph9ik6";
      type = "gem";
    };
    version = "0.1.1";
  };
  rubocop = {
    dependencies = ["jaro_winkler" "parallel" "parser" "rainbow" "rexml" "ruby-progressbar" "unicode-display_width"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1i8pw7p4dk11xpahs0j6vlvqlv3rgapaccj933g0i34hbx392lj8";
      type = "gem";
    };
    version = "0.80.1";
  };
  ruby-progressbar = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1k77i0d4wsn23ggdd2msrcwfy0i376cglfqypkk2q77r2l3408zf";
      type = "gem";
    };
    version = "1.10.1";
  };
  ruby-swagger = {
    dependencies = ["addressable"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kpjyyqj6dqsf9qjlz3aybr3hrxpjqmqdzfqm0cil2lpi84z0kah";
      type = "gem";
    };
    version = "0.1.1";
  };
  ruby_regex = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10rz8k1qp46nwf0s5h7zi5jxpdvidn6d9c3mcss5z4n5k6ljda38";
      type = "gem";
    };
    version = "0.1.3";
  };
  rubyXL = {
    dependencies = ["nokogiri" "rubyzip"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pjygqxd061fjmawklbx8c3srciw0fx6fjf1lhjlk4pki8hp5szi";
      type = "gem";
    };
    version = "3.4.14";
  };
  rubyzip = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0590m2pr9i209pp5z4mx0nb1961ishdiqb28995hw1nln1d1b5ji";
      type = "gem";
    };
    version = "2.3.0";
  };
  schema_monkey = {
    dependencies = ["activerecord" "modware"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jbg4irvaznjyv9awcycfnq5kcwf98sg77wv94i7p5b292mnx6d2";
      type = "gem";
    };
    version = "2.1.5";
  };
  schema_plus_core = {
    dependencies = ["activerecord" "its-it" "schema_monkey"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zlvxxa3fmxq1i18c84r479dmph24mbk3nrdab30zb6w5n8xp648";
      type = "gem";
    };
    version = "1.0.2";
  };
  schema_plus_enums = {
    dependencies = ["activerecord" "its-it" "schema_plus_core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ys4ch2vgisi74p99s4by2yh1d83cn2m2zfj2p11wrvg7f7fyjp7";
      type = "gem";
    };
    version = "0.1.8";
  };
  sentry-raven = {
    dependencies = ["faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k6a6ki0gafhq50w2hkg9yn7g2rp7lzy57kc2ai2fxsh68brphh4";
      type = "gem";
    };
    version = "3.0.0";
  };
  sequel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gqqnqrfayhwhkp0vy3frv68sgc7klyd6mfisx1j3djjvlyc7hmr";
      type = "gem";
    };
    version = "5.30.0";
  };
  shellany = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ryyzrj1kxmnpdzhlv4ys3dnl2r5r3d2rs2jwzbnd1v96a8pl4hf";
      type = "gem";
    };
    version = "0.0.1";
  };
  sidekiq = {
    dependencies = ["connection_pool" "rack" "rack-protection" "redis"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wn33n5vmbj62layfryry0gahahkqxlkp4g83rqv3qvhs1rymcr2";
      type = "gem";
    };
    version = "5.2.8";
  };
  sixarm_ruby_unaccent = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11237b8r8p7fc0cpn04v9wa7ggzq0xm6flh10h1lnb6zgc3schq0";
      type = "gem";
    };
    version = "1.2.0";
  };
  slim = {
    dependencies = ["temple" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ppw2rydfv7k4snnryfmc9jkyjgrdkxkipylclh9i61ifwxc14qs";
      type = "gem";
    };
    version = "4.0.1";
  };
  smarter_csv = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bkcdiyj1idb9jsl2y111bsl3p27a6ryf7yackj2fkfrv0bwmvlv";
      type = "gem";
    };
    version = "1.2.6";
  };
  sprockets = {
    dependencies = ["concurrent-ruby" "rack"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "182jw5a0fbqah5w9jancvfmjbk88h8bxdbwnl4d3q809rpxdg8ay";
      type = "gem";
    };
    version = "3.7.2";
  };
  sprockets-rails = {
    dependencies = ["actionpack" "activesupport" "sprockets"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ab42pm8p5zxpv3sfraq45b9lj39cz9mrpdirm30vywzrwwkm5p1";
      type = "gem";
    };
    version = "3.2.1";
  };
  temple = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "060zzj7c2kicdfk6cpnn40n9yjnhfrr13d0rsbdhdij68chp2861";
      type = "gem";
    };
    version = "0.8.2";
  };
  thor = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xbhkmyhlxwzshaqa7swy2bx6vd64mm0wrr8g3jywvxy7hg0cwkm";
      type = "gem";
    };
    version = "1.0.1";
  };
  thread_safe = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
  };
  tilt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rn8z8hda4h41a64l0zhkiwz2vxw9b1nb70gl37h1dg2k874yrlv";
      type = "gem";
    };
    version = "2.0.10";
  };
  timecop = {
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0d7mm786180v4kzvn1f77rhfppsg5n0sq2bdx63x9nv114zm8jrp";
      type = "gem";
    };
    version = "0.9.1";
  };
  tzinfo = {
    dependencies = ["thread_safe"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04f18jdv6z3zn3va50rqq35nj3izjpb72fnf21ixm7vanq6nc4fp";
      type = "gem";
    };
    version = "1.2.6";
  };
  unicode-display_width = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pppclzq4qb26g321553nm9xqca3zgllvpwb2kqxsdadwj51s09x";
      type = "gem";
    };
    version = "1.6.1";
  };
  unicode_utils = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h1a5yvrxzlf0lxxa1ya31jcizslf774arnsd89vgdhk4g7x08mr";
      type = "gem";
    };
    version = "1.4.0";
  };
  validates_zipcode = {
    dependencies = ["activemodel"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jc1nkfpd4328f4yqfayxi7vzp7anmzzkqb37l6z1x3bvg9g4k0b";
      type = "gem";
    };
    version = "0.2.4";
  };
  wicked_pdf = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0x1yzp818w2yh2l6yh37rrv5434qh9ih0agismnbix79zp6c4zz6";
      type = "gem";
    };
    version = "2.0.2";
  };
  wkhtmltopdf-binary-edge = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0y2w09yynnqj5vzbivjpkrxfkilhw4zn7yrc49sac54315bb2nhr";
      type = "gem";
    };
    version = "0.12.4.0";
  };
}