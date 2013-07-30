require 'test_helper'

class ConditionImporterTest < MiniTest::Unit::TestCase
  def test_condition_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)
    patient.save!
    condition = patient.conditions[0]

    assert_equal 'CD', condition.type
    assert_equal 'HEART FAILURE*', condition.description
    assert_equal 'active', condition.status
    #print "provider: " + condition.treating_provider.to_s + "\n"
    #assert_equal 'xyz', condition.treating_provider.inspect
    #assert_equal  'doctor', condition.treating_provider[0]['given_name']
    #assert_equal  'doe', condition.treating_provider[0]['family_name']
    print "cod: " + condition.cause_of_death.to_s + "\n"
    #assert ! condition.cause_of_death
    assert condition.codes['ICD9'].include? '428'
    assert 1362441600, condition.time
    assert_equal Time.gm(2013,'mar',5).to_i, condition.start_time

  end
end
