describe 'Plugin', ->
  beforeEach ->
    @plugin = new Plugin
      paths: root: '.'

  it 'should be a brunch plugin', ->
    expect(@plugin.brunchPlugin).to.be.true

  it 'should be a template plugin', ->
    expect(@plugin.type).to.equal 'template'

  it 'should handle the `jade` extension', ->
    expect(@plugin.extension).to.equal 'jade'
