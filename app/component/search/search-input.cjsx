React             = require 'react'
ReactAutowhatever = (require 'react-autowhatever').default
SuggestionItem    = require './suggestion-item'
SearchActions     = require '../../action/search-actions'

class SearchInput extends React.Component

  constructor: (props) ->
    @state =
      focusedItemIndex: 0

  @contextTypes:
    executeAction: React.PropTypes.func.isRequired
    getStore: React.PropTypes.func.isRequired

  componentWillMount: =>
    @context.getStore('SearchStore').addChangeListener @onSearchChange

  componentWillUnmount: =>
    @context.getStore('SearchStore').removeChangeListener @onSearchChange

  onSearchChange: =>
    if @context.getStore('SearchStore').getPosition() != undefined
      @handleUpdateInputNow(target:
        value: @context.getStore('SearchStore').getPosition().address)

  handleOnMouseEnter: (event, eventProps) =>
    if typeof eventProps.itemIndex != 'undefined'
      if eventProps.itemIndex != @state.focusedItemIndex
        @setState "focusedItemIndex": eventProps.itemIndex
      event.preventDefault()

  blur: () ->
    #hide safari keyboard
    @refs.autowhatever.refs.input.blur()

  handleOnKeyDown: (event, eventProps) =>

    if event.keyCode == 13 #enter selects current
      @currentItemSelected()
      @blur()
      event.preventDefault()

    if event.keyCode == 27 #esc clears
      return @handleUpdateInputNow(target:
        value: "")
      event.preventDefault()

    if (typeof eventProps.newFocusedItemIndex != 'undefined')
      @setState "focusedItemIndex": eventProps.newFocusedItemIndex,
        () -> document.getElementById("react-autowhatever-suggest--item-" + eventProps.newFocusedItemIndex)?.scrollIntoView(false)

      event.preventDefault()

  handleOnMouseDown: (event, eventProps) =>
    if typeof eventProps.itemIndex != 'undefined'
      @setState "focusedItemIndex": eventProps.itemIndex, () => @currentItemSelected()
      @blur()
      event.preventDefault()

  handleUpdateInputNow: (event) =>
    input = event.target.value

    if input == @state?.value
      return

    @setState "value": input
    geoLocation = @context.getStore('PositionStore').getLocationState()
    @context.getStore('SearchStore').getSuggestions input, geoLocation, (suggestions) =>
      @setState "suggestions": suggestions, focusedItemIndex: 0,
        () =>  if suggestions.length > 0
          document.getElementById("react-autowhatever-suggest--item-0").scrollIntoView()

  currentItemSelected: () =>
    if(@state.focusedItemIndex >= 0 and @state.suggestions.length > 0)
      item = @state.suggestions[@state.focusedItemIndex]
      name = SuggestionItem.getName item.properties
      save = () ->
        @context.executeAction SearchActions.saveSearch,
          "address": name
          "geometry": item.geometry
      setTimeout save, 0

      @props.onSuggestionSelected(name, item)

  render: =>
    <ReactAutowhatever
      ref = "autowhatever"
      className={@props.className}
      id="suggest"
      items={@state?.suggestions || []}
      renderItem={(item) ->
        <SuggestionItem ref={item.name} item={item} spanClass="autosuggestIcon"/>}
      getSuggestionValue={(suggestion) ->
        SuggestionItem.getName(suggestion.properties)
      }
      onSuggestionSelected={@currentItemSelected}
      focusedItemIndex={@state.focusedItemIndex}
      inputProps={
        "id": "autosuggest-input"
        "value": @state?.value || ""
        "onChange": @handleUpdateInputNow
        "onKeyDown": @handleOnKeyDown
        "placeholder": @context.getStore('SearchStore').getPlaceholder()
      }
      itemProps={
        "onMouseEnter": @handleOnMouseEnter
        "onMouseDown": @handleOnMouseDown
        "onMouseTouch": @handleOnMouseDown
      }
    />

module.exports = SearchInput
