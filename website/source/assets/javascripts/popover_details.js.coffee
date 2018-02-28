class window.PopoverDetail extends Backbone.View

  initialize: (options) ->
    _.defaults(options, @defaults)
    _.bindAll(@, 'render' )
    @render()

  events:
    'click .dropdown-menu a': 'select'

  render: ->
    # add div to put the new links
    $(@el).append('<div class="details"></div>')

  select: (event) ->
    event.preventDefault()
    event.stopImmediatePropagation()
    # render links
    @links(event.target.id)

  links: (id) ->
    # empty the div
    $(@el).find(".details").empty()
    # copy links
    links = $(@el).find('.jsPopoverDetailLinks').clone()
    # change title
    links.find('.list-header').append(id)
    # change urls
    links.find('a').each (index, element) ->
      url = $(this).attr('href').replace('+++', id)
      $(this).attr('href', url)

    links.removeClass('hide')
    $(@el).find(".details").append(links)

    $(@el).find('.dropdown').removeClass('open')

$.fn.initPopoverDetail = (options) ->
  options = options || {}
  _.each(@, (item) ->
    options.el = item
    new PopoverDetail(options)
  )

$ ->
