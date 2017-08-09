class GroupsController < ApplicationController
  def show
    @group = Group.find(params[:id])
    @users = User.all
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.find(params[:id])
  end

  def index
    @groups = Group.all
  end
  
  def members
    @group = Group.find(params[:group_id])
    @users = User.all
  end
  
  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(group_params)
      redirect_to @group
    else
      render 'edit'
    end
	end
  
  def create
		@group = Group.new(group_params)
		if @group.save
			flash[:success] = "New Group has been created."
			redirect_to groups_url
		else
			render 'new'
		end
	end

  def destroy
    Group.find(params[:id]).destroy
    flash[:success] = "Group deleted"
    redirect_to groups_url
  end
  
  def assign
		@group = Group.find(params[:group_id])
		user = User.find(params[:format])
		@group.users << user
		redirect_to group_members_path(@group)
	end
	
	def unassign
		@group = Group.find(params[:group_id])
		user = User.find(params[:format])
		@group.users.delete user
		redirect_to group_members_path(@group)
	end
	
	def make_administrator
		@group = Group.find(params[:group_id])
		user = User.find(params[:format])
		@group.make_admin(user)
		redirect_to group_members_path(@group)
	end
	
	def remove_administrator
		@group = Group.find(params[:group_id])
		user = User.find(params[:format])
		@group.remove_admin(user)
		redirect_to group_members_path(@group)
	end
  
  private
    def group_params
      params.require(:group).permit(:name,:group_type,:description)
    end
end
