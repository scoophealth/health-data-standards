require 'test_helper'

module E2E
class ConditionImporterTest < MiniTest::Unit::TestCase
  def test_condition_importing
    doc = Nokogiri::XML(File.new('test/fixtures/JOHN_CLEESE_1_25091940.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)
    patient.save!

    assert_equal 4, patient.conditions.size
    condition = patient.conditions[0]

    assert_equal 'CD', condition.type
    #assert ! condition.cause_of_death
    assert condition.codes['ICD9'].include?('428')
    assert_equal Time.gm(2013,'mar',5).to_i, condition.start_time

    assert_equal 'HEART FAILURE*', condition.description
    assert_equal 'active', condition.status

    #print "provider: " + condition.treating_provider.to_s + "\n"
    #assert_equal 'xyz', condition.treating_provider.inspect
    #assert_equal  'doctor', condition.treating_provider[0]['given_name']
    #assert_equal  'doe', condition.treating_provider[0]['family_name']

    condition = patient.conditions[1]
    assert_equal 'CD', condition.type
    assert condition.codes['ICD9'].include? '401'
    assert_equal Time.gm(2013,'mar',5).to_i, condition.start_time
    assert_equal 'ESSENTIAL HYPERTENSION*', condition.description
    assert_equal 'active', condition.status

    condition = patient.conditions[2]
    assert_equal 'CD', condition.type
    assert condition.codes['ICD9'].include? '250'
    assert_equal Time.gm(2013,'mar',5).to_i, condition.start_time
    assert_equal 'DIABETES MELLITUS*', condition.description
    assert_equal 'active', condition.status

    condition = patient.conditions[3]
    assert_equal 'CD', condition.type
    assert condition.codes['ICD9'].include? '491'
    assert_equal Time.gm(2013,'mar',5).to_i, condition.start_time
    assert_equal 'CHRONIC BRONCHITIS*', condition.description
    assert_equal 'active', condition.status


  end


  def test_complete_example_condition_importing
    doc = Nokogiri::XML(File.new('test/fixtures/PITO/E2E-DTC Ex 001 - Conversion - Fully Loaded - V1-30-00.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    pi = HealthDataStandards::Import::E2E::PatientImporter.instance
    patient = pi.parse_e2e(doc)
    patient.save!

    assert_equal 1, patient.conditions.size
    condition = patient.conditions[0]

    assert_equal 'CD', condition.type
    #assert ! condition.cause_of_death
    assert condition.codes['ICD9'].include?('401')
    assert_equal Time.gm(2001,8,14).to_i, condition.start_time

    assert_equal 'Bacterial Infection', condition.description
    assert_equal 'active', condition.status

    #print "provider: " + condition.treating_provider.to_s + "\n"
    #assert_equal 'xyz', condition.treating_provider.inspect
    #assert_equal  'doctor', condition.treating_provider[0]['given_name']
    #assert_equal  'doe', condition.treating_provider[0]['family_name']

  end
end
end
