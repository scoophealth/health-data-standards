require 'test_helper'

class ConditionImporterTest < MiniTest::Unit::TestCase
  def test_condition_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)
    patient.save!
    #condition = patient.conditions[0]

    #assert_equal 'Condition', condition.type
    #assert ! condition.cause_of_death
    #assert condition.codes['SNOMED-CT'].include? '195967001'
    #assert_equal Time.gm(1950).to_i, condition.start_time

  end
end