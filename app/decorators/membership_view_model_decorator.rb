class MembershipViewModelDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers
  decorates_association :group

  def edit_group_button
    return unless membership_view_model.leader?
    link_to('Adatok szerkesztése', edit_group_path(membership_view_model.group),
      class: 'uk-button uk-button-primary uk-width-3-4')
  end

  def edit_group_delegates_button
    return unless membership_view_model.leader? && membership_view_model.group.issvie
    link_to('Küldöttek', group_delegates_path(membership_view_model.group),
      class: 'uk-button uk-button-primary uk-width-3-4')
  end

  def join_group_button
    return unless membership_view_model.group.users_can_apply && !member?(membership_view_model.group, current_user)
    form_tag group_memberships_path(membership_view_model.group), {method: 'post'} do
      button_tag('Jelentkezés körbe', {class: 'uk-button uk-button-primary uk-width-3-4'})
    end
  end

end
