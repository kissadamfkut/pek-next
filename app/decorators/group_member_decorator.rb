class GroupMemberDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  def svie_status_icon
    return unless membership.active?
    if !user.svie.member? || user.svie.in_processing?
      content_tag(:span, '', class: 'uk-icon-remove', 'data-uk-tooltip': '',
                  title: 'Nem SVIE tag')
    elsif user.svie.outside_member?
      content_tag(:span, '', class: 'uk-icon-heart', 'data-uk-tooltip': '',
                  title: 'Pártolótag')
    elsif !primary_member?
      content_tag(:span, '', class: 'uk-icon-check-square',
                  'data-uk-tooltip': '', title: 'Más elsődleges kör')
    elsif user.svie.inside_member?
      content_tag(:span, '', class: 'uk-icon-check', 'data-uk-tooltip': '',
                  title: 'Rendes tag')
    end
  end

  def membership_time
    return "#{l membership_start} - #{l membership_end}" if membership.inactive?
    "#{l membership_start} -"
  end

  def edit_post_button(group)
    return if membership.inactive?
    form_tag(group_membership_posts_path(group.id, membership_id),
             method: :get, class: 'uk-form') do
      button_tag('', name: nil, class: 'uk-icon-edit uk-button uk-button-small',
                 'data-uk-tooltip': '', title: 'Posztok szerkesztése')
    end
  end

  def approve_join_button(group)
    return unless membership.newbie? && membership.active?
    button_to 'Elfogadás',
              group_membership_accept_path(group.id, membership_id),
              method: :post, remote: true,
              class: 'uk-button uk-button-success uk-button-small uk-width-auto'
  end

  def inactivate_user_button(group)
    return unless !membership.newbie? && membership.active?
    button_to 'Öreggé avatás',
              group_membership_inactivate_path(group.id, membership_id),
              method: :post, remote: true,
              class: 'uk-button uk-button-primary uk-button-small uk-width-auto'
  end

  def archive_user_button(group)
    return if membership.archived?
    button_to 'Archiválás',
              group_membership_archive_path(group.id, membership_id),
              method: :put, remote: true,
              class: 'uk-button uk-button-danger uk-button-small uk-width-auto'
  end

  def reactivate_user_button(group)
    return unless membership.inactive?
    button_to 'Újraaktiválás',
              group_membership_reactivate_path(group.id, membership_id),
              method: :post, remote: true,
              class: 'uk-button uk-button-primary uk-button-small uk-width-auto'
  end

  def unarchive_user_button(group)
    return unless membership.archived? && current_user.roles.pek_admin?
    button_to 'Archiválás visszavonása',
              group_membership_unarchive_path(group.id, membership_id),
              method: :put, remote: true,
              class: 'uk-button uk-button-danger uk-button-small uk-width-auto'
  end
end
