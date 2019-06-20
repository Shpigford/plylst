// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require extendext
//= require dot
//= require_tree .


$(document).on('turbolinks:load', function() {
  $('[data-toggle="select"]').select2();

  $(".date_picker").flatpickr({
    dateFormat: "Y-m-d",
  });

  var rules_basic = {};

  const template = {
      group: '\
      <div id="{{= it.group_id }}" class="rules-group-container"> \
        <div class="rules-group-header"> \
          <div class="btn-group pull-left group-actions"> \
            <button type="button" class="btn btn-xs btn-primary" data-add="rule"> \
              <i class="{{= it.icons.add_rule }}"></i> {{= it.translate("add_rule") }} \
            </button> \
            {{? it.settings.allow_groups===-1 || it.settings.allow_groups>=it.level }} \
              <button type="button" class="btn btn-xs btn-success" data-add="group"> \
                <i class="{{= it.icons.add_group }}"></i> {{= it.translate("add_group") }} \
              </button> \
            {{?}} \
            {{? it.level>1 }} \
              <button type="button" class="btn btn-xs btn-danger" data-delete="group"> \
                <i class="{{= it.icons.remove_group }}"></i> {{= it.translate("delete_group") }} \
              </button> \
            {{?}} \
          </div> \
          {{? it.settings.display_errors }} \
            <div class="error-container"><i class="{{= it.icons.error }}"></i></div> \
          {{?}} \
        </div> \
        <div class=rules-group-body> \
          <div class=rules-list></div> \
        </div> \
      </div>',
      rule: '\
        <div id="{{= it.rule_id }}" class="rule-container"> \
          <div class="rule-header"> \
            <div class="btn-group float-right rule-actions"> \
              <button type="button" class="btn btn-xs btn-danger" data-delete="rule"> \
                <i class="{{= it.icons.remove_rule }}"></i> \
              </button> \
            </div> \
          </div> \
          {{? it.settings.display_errors }} \
            <div class="error-container"><i class="{{= it.icons.error }}"></i></div> \
          {{?}} \
          <div class="rule-filter-container"></div> \
          <div class="rule-operator-container"></div> \
          <div class="rule-value-container"></div> \
        </div>'
    }

    // var options = {}
    // options.templates = template
    // options.filters = filters
    // options.rules = rules

  $('#builder').queryBuilder({
    filters: [
      {
        id: 'track_name',
        label: 'Track Name',
        type: 'string',
        operators: ['contains']
      }, 
      {
        id: 'artist_name',
        label: 'Artist Name',
        type: 'string',
        operators: ['contains']
      },
      {
        id: 'days_ago',
        label: 'Days Ago',
        type: 'integer',
        operators: ['less','greater']
      },
      {
        id: 'bpm',
        label: 'BPM',
        type: 'integer',
        operators: ['less','greater']
      },
      {
        id: 'release_date_start',
        label: 'Release Date',
        type: 'date',
        operators: ['between']
      }
    ],
    /*rules: rules_basic,*/
    allow_groups: 0,
    conditions: ['AND'],
    sort_filters: true,
    inputs_separator: 'and',
    select_placeholder: ' ',
    icons: {
      add_group: 'fas fa-plus-square',
      add_rule: 'fas fa-plus',
      remove_group: 'fas fa-minus-square',
      remove_rule: 'far fa-trash-alt',
      error: 'fas fa-exclamation-circle'
    },
    templates: template,
    rules: JSON.parse($('#original_filters').val())
  });

  $('#builder').on('afterUpdateRuleValue.queryBuilder afterUpdateRuleFilter.queryBuilder afterUpdateRuleOperator.queryBuilder afterUpdateGroupCondition.queryBuilder', function(){
    $('#playlist_filters').val(
      JSON.stringify($('#builder').queryBuilder(
        'getRules', 
        {skip_empty:  true}
      ))
    );
  });

});