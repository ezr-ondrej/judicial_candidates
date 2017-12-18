class CandidatesController < ApplicationController
  layout 'card', only: [:new, :edit, :show]

  load_and_authorize_resource

  def index
    azahara_schema_index
  end

  def show
  end

  def new
    raise CanCan::AccessDenied.new(current_ability.unauthorized_message(:create, Candidate), :create, Candidate) if current_candidate
    @candidate.user = current_user
  end

  def create
    @candidate.user_id = current_user.id
    @candidate.state = 'incomplete'
    respond_to do |format|
      if @candidate.save
        format.html{ redirect_to @candidate }
      else
        format.html{ render 'new' }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @candidate.update(update_params)
        format.html{ redirect_to @candidate }
      else
        format.html{ render 'new' }
      end
    end
  end

  def finalize
    authorize!(:manage, @candidate)
    @candidate.finalize
    redirect_to @candidate
  end

  def approve
    authorize!(:manage, @candidate)
    @candidate.approve
    CandidateMailer.approved_notification(@candidate).deliver_later
    redirect_to candidates_path
  end

  def disapprove
    authorize!(:manage, @candidate)
    @candidate.disapprove
    redirect_to candidates_path
  end


  private

    def create_params
      params.require(:candidate).permit( :birth_date, :phone, :university, :graduation_year, :higher_title, {organizations: [], suborganizations: []}, :shorter_invitation, :agreed_limitations, :diploma)
    end

    def update_params
      create_params
    end

end
