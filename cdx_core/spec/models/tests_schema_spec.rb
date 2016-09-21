require 'spec_helper'

describe TestsSchema do

  context "tests fields" do

    it "renders all tests scopes" do
      expect(TestsSchema.new.build['properties'].keys).to contain_exactly("sample", "test", "device", "institution", "site", "patient", "encounter")
    end

  end

  context "common functionality" do

    it "creates a schema with string, enum and number fields" do
      sample_fields = {
        "fields" => {
          "uuid" => {
            "searchable" => true,
          }
        }
      }

      patient_fields = {
        "fields" => {
          "age" => {
            "type" => "integer"
          },
          "gender" => {
            "type" => 'enum',
            "options" => ['male', 'female']
          }
        }
      }

      sample_scope = Cdx::Scope.new('sample', sample_fields)
      patient_scope = Cdx::Scope.new('patient', patient_fields)
      allow(Cdx::Fields.test).to receive(:core_field_scopes).and_return([sample_scope, patient_scope])

      schema = TestsSchema.new("es-AR").build

      expect(schema["$schema"]).to eq("http://json-schema.org/draft-04/schema#")
      expect(schema["type"]).to eq("object")
      expect(schema["title"]).to eq("es-AR")

      expect(schema["properties"]["sample"]).to eq({
        "type" => "object",
        "title" => "Sample",
        "properties" => {
          "uuid" => {
            "title" => "Uuid",
            "type" => "string",
            "searchable" => true
          },
        }
      })

      expect(schema["properties"]["patient"]).to eq({
        "type" => "object",
        "title" => "Patient",
        "properties" => {
          "age" => {
            "title" => "Age",
            "type" => "integer",
            "searchable" => false
          },
          "gender" => {
            "title" => "Gender",
            "type" => "string",
            "enum" => ["male", "female"],
            "values" => {
              "male" => { "name" => "Male" },
              "female" => { "name" => "Female" }
            },
            "searchable" => false
          }
        }
      })
    end

    it "shows condition field as enum" do
      Condition.create! name: "foo"
      Condition.create! name: "bar"
      schema = TestsSchema.new("es-AR").build

      condition_field = schema["properties"]["test"]["properties"]["assays"]["items"]["properties"]["condition"]
      expect(condition_field["enum"]).to eq(["bar", "foo"])
    end

  end

end
