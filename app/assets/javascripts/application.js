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
  var rules_basic = {};

  const template = {
      group: '\
      <div id="{{= it.group_id }}" class="rules-group-container"> \
        <div class=rules-group-body> \
          <div class=rules-list></div> \
        </div> \
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
      </div>',
      rule: '\
        <div id="{{= it.rule_id }}" class="rule-container"> \
          <div class="rule-header"> \
            <div class="btn-group float-right rule-actions"> \
              <button type="button" class="btn btn-xs btn-link text-danger" data-delete="rule"> \
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

  if ($('#original_filters').length > 0){
    if ($('#original_filters').val() === "{}") {
      rules = null;
    } else {
      rules = JSON.parse($('#original_filters').val());
    }
  }

    // var options = {}
    // options.templates = template
    // options.filters = filters
    // options.rules = rules
  if ($('#builder').length > 0){
    $('#builder').queryBuilder({
      filters: [
        {
          id: 'track_name',
          label: 'Track Name',
          type: 'string',
          operators: ['contains'],
          unique: true,
          description: 'Text the track name contains'
        }, 
        {
          id: 'artist_name',
          label: 'Artist Name',
          type: 'string',
          operators: ['contains'],
          unique: true,
          description: 'Text the artist name contains'
        },
        {
          id: 'days_ago',
          label: 'Days Ago',
          type: 'integer',
          operators: ['less','greater'],
          unique: true,
          description: 'How many days ago was the song added?'
        },
        {
          id: 'bpm',
          label: 'BPM',
          type: 'integer',
          operators: ['less','greater'],
          unique: true,
          description: 'What BPM (Beats Per Minute) do you like?'
        },
        {
          id: 'release_date',
          label: 'Release Date',
          type: 'date',
          operators: ['between'],
          unique: true,
          description: 'When were the tracks released?',
          plugin: 'datepicker',
          plugin_config: {
            format: 'yyyy-mm-dd',
            assumeNearbyYear: true,
            autoclose: true
          }
        },
        // {
        //   id: 'genres',
        //   label: 'Genres',
        //   type: 'string',
        //   operators: ['contains'],
        //   unique: true,
        //   description: 'Comma-separated genres you\'d like to limit to. <a href="http://everynoise.com/everynoise1d.cgi?scope=all&vector=popularity">Here\'s a useful list</a> of the 3000+ genres Spotify supports. 🤯'
        // },
        {
          id: 'genres',
          label: 'Genres',
          type: 'string',
          input: 'select',
          operators: ['contains'],
          plugin: 'selectpicker',
          values: {
              1: 'Books',
              2: 'Movies',
              3: 'Music',
              4: 'Tools',
              5: 'Goodies',
              6: 'Clothes'
          },
          plugin_config: {
              liveSearch: true,
              width: 'auto',
              selectedTextFormat: 'values',
              liveSearchStyle: 'contains',
          },
          multiple: true,
          unique: true,
          description: 'Comma-separated genres you\'d like to limit to. <a href="http://everynoise.com/everynoise1d.cgi?scope=all&vector=popularity">Here\'s a useful list</a> of the 3000+ genres Spotify supports. 🤯'
        },
        {
          id: 'plays',
          label: 'Play Count',
          type: 'integer',
          operators: ['less','greater'],
          unique: true,
          description: 'How many plays does this song have? NOTE: This count only starts <b>after</b> you connect to PLYLST.'
        },
        {
          id: 'duration',
          label: 'Duration',
          type: 'integer',
          operators: ['less','greater'],
          unique: true,
          description: 'How long, in seconds, is the song?'
        },
        {
          id: 'last_played_days_ago',
          label: 'Days Since Last Played',
          type: 'integer',
          operators: ['less','greater'],
          unique: true,
          description: 'How many days ago was the song last played? NOTE: This data is only available for songs played <b>after</b> you connect to PLYLST.'
        },
        {
          id: 'key',
          label: 'Key',
          type: 'integer',
          input: 'select',
          values: [
            {'0': 'C'},
            {'1': 'C♯, D♭'},
            {'2': 'D'},
            {'3': 'D♯, E♭'},
            {'4': 'E'},
            {'5': 'F'},
            {'6': 'F♯, G♭'},
            {'7': 'G'},
            {'8': 'G♯, A♭'},
            {'9': 'A'},
            {'10': 'A♯, B♭'},
            {'11': 'B'}
          ],
          operators: ['equal'],
          plugin: 'selectpicker',
          unique: true,
          description: 'The estimated key of the song'
        },
        {
          id: 'danceability',
          label: 'Danceability',
          type: 'integer',
          input: 'select',
          values: [
            {'0': 'Not at all'},
            {'1': 'A little'},
            {'2': 'Somewhat'},
            {'3': 'Moderately'},
            {'4': 'Very'},
            {'5': 'Super'},
          ],
          operators: ['equal'],
          plugin: 'selectpicker',
          unique: true,
          description: 'How danceable is the track?'
        },
      ],
      /*rules: rules_basic,*/
      allow_groups: 0,
      conditions: ['AND'],
      sort_filters: true,
      inputs_separator: '<span class="separator">and</span>',
      select_placeholder: ' ',
      display_errors: false,
      lang: {
        operators: {
          less: 'less than',
          greater: 'greater than',
          equal: 'is',
        }
      },
      icons: {
        add_group: 'fas fa-plus-square',
        add_rule: 'fas fa-plus',
        remove_group: 'fas fa-minus-square',
        remove_rule: 'far fa-trash-alt',
        error: 'fas fa-exclamation-circle'
      },
      plugins: {
        'unique-filter': null,
        'filter-description': { mode: 'inline'},
        'bt-selectpicker': null
      },
      templates: template,
      rules: rules
    });

    $('#builder').on('afterUpdateRuleValue.queryBuilder afterUpdateRuleFilter.queryBuilder afterUpdateRuleOperator.queryBuilder afterUpdateGroupCondition.queryBuilder', function(){
      $('#playlist_filters').val(
        JSON.stringify($('#builder').queryBuilder(
          'getRules', 
          {skip_empty:  true}
        ))
      );
    });
  }

});