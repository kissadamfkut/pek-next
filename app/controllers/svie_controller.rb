class SvieController < ApplicationController
  before_action :require_login
  before_action :require_privileges_of_rvt, only: [:index, :approve]

  def new
    redirect_to svie_edit_path unless current_user.primary_membership
  end

  def create
    params.permit(:svie_member_type)
    update_params = params.permit(:home_address, :mother_name, :place_of_birth, :birth_name, :email)
    current_user.update(update_params)

    begin
      date_of_birth = params[:date_of_birth].to_date
    rescue Exception => e
      return redirect_to new_svie_path, alert: t(:bad_date_format)
    else
      current_user.update!(date_of_birth: date_of_birth)
    end

    current_user.svie.create_request(params[:svie_member_type])
    redirect_to svie_successful_path, notice: t(:applied_succesful)
  end

  def edit
    @svie_memberships = current_user.memberships.select { |m| m.group.issvie }
    redirect_back alert: t(:svie_group_needed) if @svie_memberships.empty?
  end

  def update
    current_user.update(svie_primary_membership: params[:svie][:primary_membership])
    current_user.update(delegated: false)
    if current_user.svie.member?
      redirect_to profiles_me_path, notice: t(:edit_successful)
    else
      redirect_to new_svie_path
    end
  end

  def index
    @post_requests = SviePostRequest.all
  end

  def approve
    svie_post_request = SviePostRequest.find(params[:id])
    user = User.find(svie_post_request.usr_id)
    user.update(svie_member_type: svie_post_request.member_type)
    svie_post_request.destroy
    redirect_back notice: user.full_name + ' ' + t(:accept_application)
  end

  def reject
    svie_post_request = SviePostRequest.destroy(params[:id])
    user = User.find(svie_post_request.usr_id)
    redirect_back notice: user.full_name + ' ' + t(:abort_application)
  end

  def successful_application
  end

  def application_pdf
    html = GenerateMembershipPdf.new(current_user).as_html
    kit = PDFKit.new(html, page_size: 'A4')
    pdf = kit.to_pdf

    send_data(pdf,
              filename: 'szerzodes.pdf',
              disposition: 'attachment',
              type: :pdf)
  end

  def destroy
    join_to(SvieUser::NOT_MEMBER)
  end

  def outside
    join_to(SvieUser::OUTSIDE_MEMBER)
  end

  def inside
    join_to(SvieUser::INSIDE_MEMBER)
  end

  private

  def join_to(member_type)
    return unauthorized_page unless current_user.svie.can_join_to?(member_type)
    current_user.svie.create_request(member_type)
    redirect_to profiles_me_path, notice: t(:edit_successful)
  end
end
