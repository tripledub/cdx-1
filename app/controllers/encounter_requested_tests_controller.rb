class EncounterRequestedTestsController < ApplicationController

  def update
    error_text=Hash.new
    saved_ok = false
    
    encounter = Encounter.find(params[:id])  
    current_test=''
    auth_ok = authorize_resource(encounter, UPDATE_ENCOUNTER)
    if auth_ok
     requested_tests = params["requested_tests"]
       requested_tests.each do |test|
         current_test = RequestedTest.find(test[1]["id"])
         saved_ok = current_test.update(status: test[1]["status"]) if current_test
         if saved_ok==false
           error_text = current_test.errors.messages
         end
       end 
    end
    
    if auth_ok && saved_ok==true
      render json: current_test
    else
      error_text[:error]='not authorised' if !auth_ok
      render json: error_text, status: :unprocessable_entity
    end
      
  end
end
