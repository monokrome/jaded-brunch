describe 'Plugin', ->
  beforeEach ->
    @plugin = new Plugin {}

  it 'should be a brunch plugin', ->
    expect(@plugin.brunchPlugin).to.be.true

  it 'should be a template plugin', ->
    expect(@plugin.type).to.equal 'template'
