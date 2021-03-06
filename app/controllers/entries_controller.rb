class EntriesController < ApplicationController
  layout 'aquila'
  before_filter :authenticate_user!, except: [:show]
  before_filter :member_is_able_to_edit_entry?, only: [:edit, :update]

  def show
    @entry = Entry.find(params[:id])
    @challenge = @entry.challenge
    @user = @entry.member

    return render :file => 'public/404.html', :status => :not_found, :layout => false if !@entry.public?
  end

  def new
    @challenge = Challenge.find params[:challenge_id]

    if current_user.userable.has_submitted_app?(@challenge)
      return redirect_to challenge_path(@challenge), notice: I18n.t("flash.unauthorized.already_submited_app")
    end

    unless Phases.is_current?(:ideas, @challenge)
      return redirect_to challenge_path(@challenge), notice: I18n.t("flash.unauthorized.entries_not_accepted")
    end

    @entry = @challenge.entries.build
  end

  def edit
    @challenge = Challenge.find params[:challenge_id]
    @entry = Entry.find params[:id]
    authorize! :update, @entry
  end

  def create
    authorize! :create, Entry
    @challenge = Challenge.find(params[:challenge_id])
    @entry = @challenge.entries.build(params[:entry])
    if @entry.save
      EntriesMailer.delay.send_entry_confirmation_mail_to(@challenge, current_member)
      redirect_to challenge_path(@entry.challenge), notice: Phases.entry_added_message(@challenge)
    else
      render :new
    end
  end

  def update
    @challenge = Challenge.find params[:challenge_id]
    @entry = Entry.find params[:id]
    authorize! :update, @entry
    if @entry.update_attributes(params[:entry])
      redirect_to challenge_path(@entry.challenge), notice: I18n.t("flash.entries.updated_successfully")
    else
      render :edit
    end
  end

  private

  def member_is_able_to_edit_entry?
    @challenge = Challenge.find params[:challenge_id]
    redirect_to(challenge_path(@challenge), alert: I18n.t("flash.entries.phase_due")) unless current_member.is_able_to_edit_entry?(@challenge)
  end
end
