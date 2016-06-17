class PatientPage < CdxPageBase
  set_url '/patients{/patient_id}{?query*}'

  element :add_episode, "a#add_episode"
end
