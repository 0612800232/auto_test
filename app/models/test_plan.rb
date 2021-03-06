# encoding: utf-8
require 'fileutils'
class TestPlan < ActiveRecord::Base
	attr_accessible :plan_type_id,:host, :user_name,:log_path, :name, :pd,:test_num,:user_id,:memo,:time_after,:time_every,:time_at,:time_cron,:job_id,:job_sstatus,:carbon_email

   attr_accessor :time_select
   	has_many :test_plan_cases, :dependent => :destroy
   	has_many :test_cases , :through=>:test_plan_cases
   	has_many :test_scripts, :dependent => :destroy
   	has_many :test_plan_datas, :dependent => :destroy
    has_many :test_results, :dependent => :destroy
    belongs_to :user
    belongs_to :plan_type    

   	
    def time_select

      if time_cron != nil and time_cron !=''
        return 1
      end

      if time_at != nil and time_at !=''
        return 2
      end

      if time_after != nil and time_after !=''
        return 3
      end

      if time_every != nil and time_every !=''
        return 4
      end
      return 0

    end

    def file_script
   		path = "./test_script/" + self.id.to_s 
   		control_file_path = path + "/" + self.id.to_s + "_control.rb"
   		if  File.exist? path
   			FileUtils.rm_rf path	
   		end
		Dir.mkdir(path)
   		
		control_file = File.new(control_file_path,"w")

   		self.test_scripts.each do |test_script|
   			name = path + '/' + test_script.test_plan_id.to_s + "_" + test_script.test_case_id.to_s + 
  				 test_script.id.to_s +  ".rb" 
  			scriptFile = File.new(name,"w")
  			scriptFile.write test_script.script_content 

        control_file.write "begin \r\n"
  			control_file.write "load \'" + name + "\'\r\n"

        control_file.write "testResult = TestResult.setResult(:test_script_id=>" + test_script.id.to_s + ",:test_plan_id=>" + test_script.test_plan_id.to_s + ",:test_case_id=>" + test_script.test_case_id.to_s  + ",:test_result_flag => true) \r\n"

        control_file.write "rescue Exception => e \r\n"
        control_file.write "testResult = TestResult.setResult(:test_script_id=>" + test_script.id.to_s + ",:test_plan_id=>" + test_script.test_plan_id.to_s + ",:test_case_id=>" + test_script.test_case_id.to_s  + ",:test_result_content=>e.message,:test_result_flag => false) \r\n"
        control_file.write "end \r\n"

   			scriptFile.close
  		end
  		control_file.close
   	end


   	def excuse
      begin 
		load "./test_script/" + self.id.to_s + "/" + self.id.to_s + "_control.rb"
    temp_test_plan = TestPlan.find(self.id)
    flag =  1
    temp_test_plan.test_results.each do |test_result|
      puts "用例执行结果：" + test_result.test_result_flag.to_s
      if !test_result.test_result_flag
        flag =0
        break
      end
    end

    puts "======================================================================================="
    puts '执行结果为：'  + flag.to_s
      for i in 0..2
        if flag == 0 
            if i == 2
              break
            end
            #TestResult.delete_all("test_plan_id = #{self.id}")
            load "./test_script/" + self.id.to_s + "/" + self.id.to_s + "_control.rb"
            temp_test_plan = TestPlan.find(self.id)
           temp_test_plan.test_results.each do |test_result|
            if test_result.test_result_flag == 0
              flag =0
              break
            end
          end
        else
          break
      end
    end

    ResultMailer.send_mail(self.user.email,self.id).deliver

    carbon_email.split("|").each do |email|
      ResultMailer.send_mail(email,self.id).deliver
    end
    rescue Exception => e 

    puts e
    end 

    
   	end

    def get_error_cast_num
     return  TestResult.where("test_plan_id = ? and test_result_flag = ? ",id,false).length
    end



    def get_job_status
     
      job = $scheduler.job(self.job_id)

      if job == nil
        if self.job_status !='停止'
            self.job_status = '停止'
            self.save
          end
        return "停止" 
      end

      if job.scheduled?

          if time_select == 4 
           if job.paused?
            if self.job_status !='暂停中'
              self.job_status = '暂停中'
              self.save
            end
          return "暂停中"
          end
          end

          if self.job_status !='运行中'
            self.job_status = '运行中'
            self.save
          end
          return "运行中"
      end
    
    end

end
