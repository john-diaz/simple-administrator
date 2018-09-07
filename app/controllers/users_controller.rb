class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    permission_code = PermissionCode.find_by(body: params[:user][:permission_code])

    if !permission_code && !current_user_is(1) # 422 code if there is no permission and user is not admin
      respond_to do |format|
        @user.errors.add(:_, 'Invalid permission code provided.')

        format.html { render :new }
        format.json { render :new, json: @user.errors, status: :unprocessable_entity }
      end
    else
      @user.role = current_user_is(1) ? params[:user][:role] : params[:user][:permission_code]

      respond_to do |format|
        if @user.save
          permission_code.delete if permission_code # Get rid of the permission to join if used

          format.html { redirect_to @user, notice: 'User was successfully created.' }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new }
          format.json { render :new, json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if current_user.role === 1 || same_user(@user.id) # if the current_user is admin or is the same user being edited 
        if @user.role === 1 && same_user(@user.id) # @user is an admin and you are not him (admin cannot edit admin)
          @user.errors.add(:_, "Cannot edit #{@user.first_name} because they are an admin.")

          format.html { render :edit }
          format.json { render json: @user.errors, status: :unauthorized }
        elsif current_user_is(1) || @user.authenticate(user_params[:password]) # is authenticated OR is admin
          if @user.update(user_params)
            format.html { redirect_to @user, notice: 'User was successfully updated.' }
            format.json { render :show, status: :ok, location: @user }
          else
            format.html { render :edit }
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
        else
          format.html { render :edit, notice: 'Failed authentication'}
          format.json { render json: @user.errors, status: :unauthorized }
        end
      else # you are not admin and you are not this user
        @user.errors.add(:_, "You are not permitted to edit #{@user.first_name}'s account.")

        format.html { render :edit }
        format.json { render json: @user.errors, status: :unauthorized }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :title,
        :email,
        :phone,
        :first_name,
        :last_name,
        :password_confirmation,
        :password
      )
    end
    def permission_params
      params.require(:user).permit(
        :permission_code
      )
    end
end
