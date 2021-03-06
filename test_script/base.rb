#encoding: utf-8

require 'win32api'
require 'oci8'
require 'dl'
require 'net/http'
require 'net/https'
require 'net/ssh'
def user32(name, param_types, return_value)
        Win32API.new 'user32' , name, param_types, return_value
end

$password_time = 0
$file_path = "e:\/code\/auto_test\/public\/screan_shot\/"

$key_map = {  
'1' => 201,  
'2' => 202,  
'3' => 203,  
'4' => 204,   
'5' => 205,  
'6' => 206,  
'7' => 207,  
'8' => 208,  
'9' => 209,  
'0' => 210,  
'a' => 401,  
'b' => 505,  
'c' => 503,  
'd' => 403,  
'e' => 303,  
'f' => 404,  
'g' => 405,  
'h' => 406,  
'i' => 308,  
'j' => 407,  
'k' => 408,  
'l' => 409,  
'm' => 507,  
'n' => 506,  
'o' => 309,  
'p' => 310,  
'q' => 301,  
'r' => 304,  
's' => 402,  
't' => 305,  
'u' => 307,  
'v' => 504,   
'w' => 302,  
'x' => 502,  
'y' => 306,
'z' => 501
}
$temp_copy = ""



#元素定位
def get_element(b,data,type)
  last_window_index = b.windows.length - 1
  
  for i in 0..last_window_index
    
    w = b.window(:index => last_window_index-i).use 
    puts "使用第" + (last_window_index-i).to_s + "个窗口"
    puts "当前窗口url:" + w.url 
    puts "当前窗口标题:"  + w.title
    puts "开始寻找元素:"
    puts data
    t= nil
    
    t = getByType(type, b, data)
    
    if t==nil or t.exists?
      puts "类型为：" + type + ",全量匹配，找到元素--------退出寻找"
      return t 
    else
      class_list = data[:class]
      if class_list !=nil and class_list !=''
        class_list.split(" ").each do |class_type|
          data[:class] = class_type
          
          t = getByType(type, b, data)
          
          if t.exists?
            puts "类型为：" + type + ",通过class匹配，找到元素--------退出寻找"
            return t
          end
        end
      end
      
      
      data.delete(:class)
      
      t = getByType(type, b, data)
      
      if t.exists?
        puts "类型为：" + type + ",删除class，找到元素--------退出寻找"
        return t
      end
      
      data.delete(:text)
      
      t = getByType(type, b, data)
      
      if t.exists?
        puts "类型为：" + type + ",删除text,找到元素--------退出寻找"
        return t
      end
      
      data.delete(:name)
      
      t = getByType(type, b, data)
      
      if t.exists?
        puts "类型为：" + type + ",删除name,找到元素--------退出寻找"
        return t
      end
      
      data.delete(:id)
      
      t = getByType(type, b, data)
      
      if t.exists?
        puts "类型为：" + type + ",删除id,找到元素--------退出寻找"
        return t
      end
      
    end
  end
  puts "类型为：" + type + ",找不到元素--------退出寻找1"

  msg = '找不到元素,类型: '  + type 
  screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
  begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
          end

  msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
  b.quit
  raise msg
  return t
end

def getByType type, b, data
  if (type == "input")
    t = b.text_field data
    return t 
  end
  if (type == "a")
    t = b.link data
    return t 
  end
  if (type == "button")
    t = b.button data
    return t 
  end
  
  if (type == "span")
    t = b.span data
    return t 
   end
   
  if (type == "select")
    t = b.select_list data
     return t 
	end
	

  eval("t = b."+ type + " data")
 
  
  return t 
end



#处理url
def do_url(b,url)
  b.goto url
  return b
end


#生成随机数
def newpass(len)
  newpass = ""
  1.upto(len){ |i| newpass << (rand(9) + 1).to_s}
  return newpass
end


#处理输入
def do_input(b,json,data)
  puts "华丽的分割线-----------------------------------------------------------------------"
  puts "开始处理输入------------------"


   reg = Regexp.new(".*\\#(.*)\\#.*")
   res =  reg.match(data)
   
   if res != nil and res.length ==2
      puts "数据类型为随机数类型，特殊处理---------------------------------------------------"
      rang_num = res[1]
      rang_res = newpass rang_num.to_i
      data = data.sub(/\#.*\#/, rang_res)
      puts "最终生成的随机数为：" + data + "-----------------------------------------------------"

   end

   

  old_json = json.clone
  if (json[:type] !=nil ) 
    type = json[:type]
    json.delete(:type)
      if type != 'embed' && type != 'object'
         t = get_element(b,json,type)
         if(t.exists?)
            t.focus
            t.click
            begin
            t.set data
            rescue Exception => e 
              b.quit
              raise "类型为：" + type + "," + old_json.to_s+ "该控件无法输入"
            end
            t.send_keys([:tab])
         else
          puts "找不到元素，输入结束-----------"
          msg = '找不到元素,类型: '  + type 
          screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
          

          begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
          end

          msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
          b.quit
          raise msg
        end

      else
     



        last_window_index = b.windows.length - 1
    
         w = b.window(:index => last_window_index).use 
        find_window  = user32 'FindWindowA'  , ['P' , 'P' ], 'L'

        title =  w.title.encode("GB2312") + " - Google Chrome".encode("GB2312")

       
        puts title
        dialog  = find_window.call nil, title
        puts "获取窗体: #{dialog}"

        set_fore_window = user32 'SetForegroundWindow', ['L'], 'L'
        set_fore_window.call dialog


        get_dlg_item = user32 'GetDlgItem' , ['L' , 'L' ], 'L'
        i = passwordObject('1')
        puts "控件id：" + i.to_s


        pa_object = get_dlg_item.call dialog, i


        puts "获取控件: #{pa_object}"

        get_window_rect = user32 'GetWindowRect' , ['L' , 'P' ], 'I'
        rectangle = [0, 0, 0, 0].pack 'L*'
        get_window_rect.call pa_object, rectangle
        left, top, right, bottom = rectangle.unpack 'L*'

        puts "控件坐标：" + left.to_s + right.to_s

        set_cursor_pos = user32 'SetCursorPos' , ['L' , 'L' ], 'I'
        mouse_event = user32 'mouse_event' , ['L' , 'L' , 'L' , 'L' , 'L' ], 'V'
        left_down = 0x0002
        left_up = 0x0004
        center = [(left + right) / 2, (top + bottom) / 2]
        set_cursor_pos.call *center
        mouse_event.call left_down, 0, 0, 0, 0
        mouse_event.call left_up, 0, 0, 0, 0

        dll_file = File.dirname(__FILE__)+'/DD32.dll' 

        if File::exists?(dll_file)
        puts "dll文件存在"

        end


        test  =  Win32API.new dll_file , 'DD_todc', 'I', 'I'

        result1 =  test.call 28
        puts "111" + result1.to_s
       
        initializeWinIo  =  Win32API.new dll_file , 'DD_str', 'S', 'I'
       

        key  =  Win32API.new dll_file , 'DD_key', ['I','I'], 'I'

        sleep 3
        #不知道为什么得先输入一下键盘
        key.call 600,1
         sleep 0.5
        key.call 600,2
    
        puts "开始输入：" 
        data.split("").each do |word|
          puts "输入：" + word
          key.call $key_map [word],1
          
          puts "输入码表：" + $key_map [word].to_s
          key.call $key_map [word],2
          if json[:id]=='_ocx_password'
          sleep 1
          end
        end


        #输入控件后需要将鼠标移开
        set_cursor_pos = user32 'SetCursorPos' , ['L' , 'L' ], 'I'
        mouse_event = user32 'mouse_event' , ['L' , 'L' , 'L' , 'L' , 'L' ], 'V'
        left_down = 0x0002
        left_up = 0x0004
        center = [((left + right) / 2 + 200), (top + bottom) / 2 ]
        set_cursor_pos.call *center
        mouse_event.call left_down, 0, 0, 0, 0
        mouse_event.call left_up, 0, 0, 0, 0
      
        

         
        if json[:id] == 'userpasswdNP' or json[:id] == 'userpasswdNP1'

        t = get_element(b,json,type)  
        sleep 2
        puts '先锋支付控件额外处理'
        test_script ='var userpasswd = GetActiveX();$(\'#userpasswdNP\').attr(\'test_length\',userpasswd.GetLength())'
        b.execute_script(test_script)
        sleep 0.5

        input_length = t.attribute_value('test_length')

        puts "控件输入长度为：" + input_length.to_s
        puts "控件应该输入长度为：" +  data.split("").length.to_s
        if input_length.to_i != data.split("").length
          puts "控件没有完全输入内容，再次输入"
          json[:type] = type
          do_input(b,json,data)
        end
        end
        
        
        # keybd_event = user32 'keybd_event' , ['I' , 'I' , 'L' , 'L' ], 'V'
        # keydown = 0
        # keyup = 2
        # sleep 2
        # data =  data.encode("GB2312")

        # puts data

        # i = 0
        # data.upcase.each_byte  do |b|
        #    puts "控件输入：#{i.to_s} 次" + b.to_s 
        #    i = i+ 1
        #    keybd_event.call b, 0, keydown, 0
        #     sleep 1
        #     keybd_event.call b, 0, keyup, 0
        #   sleep 1
        #  end
        
        
      end
      puts "输入成功------------------"
   
  end
  
  puts "华丽的分割线-----------------------------------------------------------------------"
  
  
  return b
end

def passwordObject(type)

  if type =='1'
    return 00000000
  end
  if type=='2'
    return 05133644
  end

end


#处理浏览器
def do_brower(b,brower)
  b = nil
  if brower =='chrome'
    b = Watir::Browser.new :chrome, :switches => %w[--allow-outdated-plugins --always-authorize-plugins --no-default-browser-check]   
  end
  
  if brower =='ie'
    b = Watir::Browser.new :ie
  end
  
  if brower =='firefox'
    b = Watir::Browser.new :firefox
  end

  b.driver.manage.window.maximize
   # 如果3s内还定位不到则抛出异常
   # b.driver.manage.timeouts.implicit_wait = 300 # seconds

  # # 页面加载超时时间设置为5s
  # b.driver.manage.page_load = 300 #seconds

  # # 异步脚本的超时时间设置成3s 
  # b.driver.manage.script_timeout = 300 #seconds
  return b 
  
end



#处理点击
def do_click(b,json,data)
  puts "华丽的分割线-----------------------------------------------------------------------"
  puts "开始处理点击------------------"
  type = json[:type]
  json.delete(:type)

  old_json = json.clone

  if type== 'input'
    puts "input类型点击判断类型为按钮，处理按钮------------------"
    t = get_element(b,json,'button')
  else
     t = get_element(b,json,type)
  end
  if t.exists?
    sleep 1
    begin
    t.click
    rescue Exception => e 
      b.quit
     raise  raise "类型为：" + type + "," + old_json.to_s + "该控件无法点击"
    end
    sleep 1
    puts "点击成功------------------"
    return b
  else
    puts "找不到元素，点击结束-----------"

    msg = '找不到元素,类型: '  + type 
    screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
    begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
          end

    msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
    b.quit
    raise msg
  end
end

def do_sleep(b,data)
  puts "开始等待" + data.to_s + "秒"
  last_window_index = b.windows.length - 1
  puts "使用第" + (last_window_index).to_s + "个窗口"
  w = b.window(:index => last_window_index).use 
  puts "当前窗口url:" + w.url 
  
  sleep_time = data.to_i


  while sleep_time > 0  do
   sleep 10 
   sleep_time = sleep_time -10 
   puts "还有" + sleep_time.to_s + "秒" ;
  end

  puts "等待" + data.to_s + "秒结束"
  return b
end

def do_select(b,json,data)

  puts "华丽的分割线-----------------------------------------------------------------------"
  puts "开始处理下拉框选择------------------"
  type = json[:type]
  json.delete(:type)
 
  t = get_element(b,json,type)

  if t.exists?
    
    t.select  data
    puts "下拉框选择成功------------------"
    return b
  else
    puts "找不到元素，点击结束-----------"

    msg = '找不到元素,类型: '  + type 
    screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
    begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
          end

    msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
    b.quit
    raise msg
  end

end



def do_assert(b,json,data)
  puts "华丽的分割线-----------------------------------------------------------------------"
  puts "开始处理对比------------------"
  type = json[:type]
  json.delete(:type)
  text = json[:text]
  json.delete(:text)
  t = get_element(b,json,type)

  dates = data.split("|")

  if t!=nil and t.exists?

    result = false

    dates.each do |d|
      reg = Regexp.new(".*" + d + ".*")
      puts "对比结果------------------------------------------------"
      puts reg 
      if reg.match(t.text())
        result = true
      end
    end


    
     if result
       puts "对比成功，进入下一步------------------"
     else
      msg = '对比失败,目前内容为: '  + t.text() 
      screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
      begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
          end

      msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
      b.quit
      raise msg
     end
    return b
  else
    puts "找不到元素，点击结束-----------"

    msg = '找不到元素,类型: '  + type 
    screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
    begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
          end

    msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
    b.quit
    raise msg
  end
end



def do_copy(b,json,data)

  puts "华丽的分割线-----------------------------------------------------------------------"
  puts "开始处理copy------------------"
  type = json[:type]
  json.delete(:type)
  text = json[:text]
  json.delete(:text)
  t = get_element(b,json,type)
  if t!=nil and t.exists?
      puts "复制内容为：" + t.text() + "---------------------------------------------------"
     $temp_copy = t.text()
      puts "复制成功，进入下一步----------------------------------------------------------"
    return b
  else
    puts "找不到元素，点击结束-------------------------------------------------------------"

    msg = '找不到元素,类型: '  + type 
    screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
    begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
     end

    msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
    b.quit
    raise msg
  end
end



def do_paste(b,json,data)
    puts "华丽的分割线-----------------------------------------------------------------------"
    puts "开始处理黏贴------------------"
    #处理输入
    puts "黏贴板里面内容为：" +  $temp_copy  + "---------------------------------------------"
   b =  do_input(b,json,$temp_copy)
   return b
end


def do_pic(b,json,data)
    puts "华丽的分割线-----------------------------------------------------------------------"
    puts "开始处理截图------------------"

    screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
    file_name =  b.name.to_s + "_" + screenshot_path
    begin 
            b.driver.save_screenshot $file_path + file_name
          rescue Exception => e 
            b.quit
     end

    msg = "页面截图成功："
    
    msg  = msg + "<a href=\'/screan_shot/" + file_name + "\' target='_blank'>查看截图</a>"
    
    json[:test_result_content] = msg
    json[:test_result_flag] = true
    TestResult.setResult(json);
    return b
end



def do_pic_test(b,json)
    puts "华丽的分割线-----------------------------------------------------------------------"
    puts "开始处理截图------------------"

    screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
    begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
     end

    msg = "页面截图成功："
    
    msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"

    return b
end




def do_checkCode(b,json,data)
  checkCode = nil
  ssh = Net::SSH.start(data[:host], data[:user], :password => data[:password]) do |ssh|

    paths = data[:log_path].split("|")

    checkCode = ''
    last_time = nil

    paths.each do |path |

    puts "远程执行命令：" + "tail -100 "+  path + "| grep '#{data[:reg].split(':')[0]}'"
    checkCode_string = ssh.exec!("tail -100 "+  path + "| grep '#{data[:reg].split(':')[0]}'")
    

    checkCode_string ||=""
    puts "get code back:---------------------------------------------" + checkCode_string

    reg = Regexp.new(data[:reg]) 
    listcode = checkCode_string.scan(reg)
      if listcode.length != 0 
        last_index = listcode.length - 1


        time_string =   checkCode_string[0,19]
       
        if last_time ==nil || Time.parse(time_string) > last_time
            last_time = Time.parse(time_string)
            checkCode =  listcode[last_index][0]
            puts "输入的验证码是：" + checkCode.to_s
        end
        

       

      end 
    end 


    if checkCode !=''
      puts "输入的验证码是：" + checkCode.to_s
      do_input b,json,checkCode
      sleep 1
      return b
    else
      msg = '后台获取验证码失败' 
      screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
      begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
          end

      msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
      b.quit
    end
  end
 
end








def CheckCode_ok(gifurl,checkCode)
#获取验证码图片
 
  url = URI.parse(gifurl)
 
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true if url.scheme == 'https'
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE #这个也很重要

  request = Net::HTTP::Get.new(url.path)

  File.open("C:\\CheckImg.jpg", "wb") do |file|
  file.write(http.request(request).body)
  file.close
  end
#end
#执行批处理文件
  system("c:\\CheckBat.bat")
#获取txt中的验证码
  if File.exists?("c:\\CheckCode.txt") ==true
    File.open("c:\\CheckCode.txt","r") do |line|
    checkCode= line.readline
    line.close
    end
  end
  puts checkCode
  return checkCode
end




#执行数据库比对
def do_db(b,json,data)

  name     = json[:name]
  password = json[:password]
  url      = json[:url]
  sql      = json[:sql]

  json.delete(:name)
  json.delete(:password)
  json.delete(:url)
  json.delete(:sql)


  type = json[:type]
  json.delete(:type)
  text = json[:text]
  json.delete(:text)
  t = get_element(b,json,type)
  if t!=nil and t.exists?
      puts "页面获取内容为：" + t.text() + "---------------------------------------------------"
      sql_date = t.text()
      puts "页面获取内容成功，进入下一步----------------------------------------------------------"
  else
    puts "找不到元素，点击结束-------------------------------------------------------------"

    msg = '找不到元素,类型: '  + type 
    screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
    begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
     end

    msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
    b.quit
    raise msg
  end


  sql["?"]= "\'" + sql_date + "\'"


  #customer/customer@10.20.5.201:1521/xfdb
  conn = OCI8.new(name, password,url)
  a =[]
 #执行查询操作
 cursor = conn.exec(sql) { |r| a<<r; puts r.join('')}
 
  page_date = ""

  data = eval(data)

  puts "开始处理数据库------------------" + data.class.to_s

  if data.class.to_s =="Hash"
  puts "开始处理数据库------------------"
  type = data[:type]
  data.delete(:type)
  text = data[:text]
  data.delete(:text)
  t = get_element(b,data,type)
  if t!=nil and t.exists?
      puts "页面获取内容为：" + t.text() + "---------------------------------------------------"
      page_date = t.text()
      puts "页面获取内容成功，进入下一步----------------------------------------------------------"
  else
    puts "找不到元素，点击结束-------------------------------------------------------------"

    msg = '找不到元素,类型: '  + type 
    screenshot_path =  Time.now.strftime("%Y-%m-%d-%H-%M-%S")+".png"
    begin 
            b.driver.save_screenshot $file_path + screenshot_path
          rescue Exception => e 
            b.quit
     end

    msg  = msg + "<a href=/screan_shot/" + screenshot_path + " target='_blank'>查看截图</a>"
    b.quit
    raise msg
  end
else
  page_date = data.to_s
end




 if a.length == 0

      msg = '数据库对比失败,没有返回任何记录'
      msg  = msg + a.to_s
      b.quit
      raise msg
 end

 if a.length > 1
      msg = '数据库对比失败,返回多条记录'
      msg  = msg + a.to_s
      b.quit
      raise msg
 end


  puts "页面获取的内容为：" + page_date
  dates = page_date.split("|")



  result = false

  dates.each do |d|

      puts "比对----------------" + d
      reg = Regexp.new(".*" + d + ".*")
      if reg.match(a[0][0].to_s)
        result = true
      end
  end


  if result
         puts "对比成功，进入下一步------------------"
  else
        msg = '对比失败,目前内容为: '  + a[0][0]
        b.quit
        raise msg
  end

  return b

end



