#encoding: utf-8
require 'watir-webdriver' 
$LOAD_PATH.unshift(File.dirname(__FILE__))
require  './test_script/base.rb'
b= nil
b = do_brower b,'chrome'
b = do_url b,'http://10.20.5.221:8083/member/login/index.htm'
b = do_input b,{:id=>"username",:type=>"input",:class=>"input-block-level n-invalid",:name=>"username",},'13757162413'
b = do_input b,{:id=>"userpasswdNP",:type=>"embed",},'123456'
b = do_checkCode b,{:id=>"checkCode",:type=>"input",:class=>"input-block-level wx add-mgt10 n-invalid",:name=>"checkCode",},''
b = do_click b,{:type=>"button",:class=>"btn btn-large btn-primary sign-in-btn",:text=>"登 录",},''
b.quit
