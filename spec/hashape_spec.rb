include Hashape

RSpec.describe Hashape do
  it "has a version number" do
    expect(Hashape::VERSION).not_to be nil
  end
  
  # These shouldn't fail unless Ruby undergoes a huge breaking change. But you
  # never know!
  context 'the === operator' do
    it 'matches objects' do
      expect(3 === 3).to be true
      expect(3 === 4).to be false
    end

    it 'matches types' do
      expect(Integer === 3).to be true
      expect(String === 3).to be false
    end
  end

  context 'specifiers' do
    they 'expect exactly one argument' do
      Specifiers::Specifier.new(String)
      expect { Specifiers::Specifier.new }.to raise_error(ArgumentError)
      expect { Specifiers::Specifier.new(String, Integer) }.to raise_error(ArgumentError)
    end

    they 'work with hashes' do
      expect(
        Specifiers::Many.new({
          foo: Integer,
          bar: String
        }) === [{
          foo: 2,
          bar: "abc"
        }, {
          foo: 3,
          bar: "def"
        }]
      )
    end

    they 'can be nested' do
      x = Specifiers::Optional.new(Specifiers::OneOf.new([Integer, String]))
      expect(x === 3).to be true
      expect(x === "foo").to be true
      expect(x === nil).to be true
      expect(x === 3.0).to be false
    end

    they 'can be created with a shorthand' do
      expect(Specifiers::Specifier[Integer]).to be_a Specifiers::Specifier
      expect(Specifiers::Optional[Integer]).to be_a Specifiers::Optional
    end

    context 'Optional' do
      let(:subject) { Specifiers::Optional }

      it 'allows nil' do
        expect(subject.new(Integer) === nil).to be true
      end

      it 'allows a value' do
        expect(subject.new(Integer) === 3).to be true
        expect(subject.new(String) === 3).to be false
      end
    end

    context 'OneOf' do
      let(:subject) { Specifiers::OneOf }

      it 'allows only its types' do
        x = subject.new([Integer, String])
        expect(x === 3).to be true
        expect(x === "foo").to be true
        expect(x === nil).to be false
        expect(x === 3.0).to be false
      end
    end

    context 'Many' do
      let(:subject) { Specifiers::Many }

      it 'allows an enumerable of its type' do
        x = subject.new(String)
        expect(x === ["foo", "bar"]).to be true
        expect(x === []).to be true
        expect(x === "foo").to be false
      end
    end
  end

  context 'shape' do
    let(:subject) { Shape }

    it 'matches correctly with a flat hash' do
      subject.new({
        success: true,
        name: String,
        age: Integer
      }).matches!({
        success: true,
        name: "Aaron",
        age: 19
      })

      expect {
        subject.new({
          success: true,
          name: String,
          age: Integer
        }).matches!({
          success: true,
          name: "Aaron",
          age: nil
        })
      }.to raise_error Hashape::ShapeMatchError

      expect {
        subject.new({
          success: true,
          name: String,
          age: Integer
        }).matches!({
          success: true,
          name: "Aaron",
          age: "19"
        })
      }.to raise_error Hashape::ShapeMatchError
    end

    it 'matches correctly with a nested hash' do
      subject.new({
        success: true,
        data: {
          name: String,
          age: Integer
        }
      }).matches!({
        success: true,
        data: {
          name: "Aaron",
          age: 19
        }
      })

      expect {
        subject.new({
          success: true,
          data: {
            name: String,
            age: Integer
          }
        }).matches!({
          success: true,
          data: {
            name: "Aaron",
            data: "19"
          }
        })
      }.to raise_error ShapeMatchError
    end

    it 'works with specifiers' do
      subject.new({
        data: Specifiers::Many.new(Integer)
      }).matches!({
        data: [1, 2, 3, 4]
      })

      expect {
        subject.new({
          data: Specifiers::Many.new(Integer)
        }).matches!({
          data: [1, 2, "foo", 4]
        })
      }.to raise_error ShapeMatchError
    end

    it 'requires keys to be present' do
      expect {
        subject.new({
          data: String
        }).matches!({})
      }.to raise_error ShapeMatchError
    end
  end
end
