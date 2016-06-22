class EncounterRequestedTestsController < ApplicationController

  def update
    error_text=Hash.new
    saved_ok = true
    
    encounter = Encounter.find(params[:id])  
    current_test=''
    auth_ok = authorize_resource(encounter, UPDATE_ENCOUNTER)
    if auth_ok
       requested_tests = params["requestedTests"]
       requested_tests.each do |test|
         current_test = RequestedTest.find(test[1]["id"])
         if test[1]["status"] != current_test.status
           current_test.status = test[1]['status']
           saved_ok = current_test.save
           if saved_ok==false
             error_text = current_test.errors.messages
            end      
         end
       end 
    end
  

#saved_ok=false
#error_text[:error]='gggggggg'
    
    if auth_ok && saved_ok==true
      render json: current_test
    else
      render json: error_text, status: :unprocessable_entity
    end
      
  end
end
