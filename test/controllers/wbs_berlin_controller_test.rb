require 'test_helper'

class WbsBerlinControllerTest < ActionController::TestCase
  setup do
    @wb_berlin = wb_berlins(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wb_berlins)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wb_berlin" do
    assert_difference('Wbberlin.count') do
      post :create, wb_berlin: { band: @wb_berlin.band, seite_start: @wb_berlin.seite_start, seite_stop: @wb_berlin.seite_stop, uid: @wb_berlin.uid, wort_id: @wb_berlin.wort_id, zeile_start: @wb_berlin.zeile_start, zeile_stop: @wb_berlin.zeile_stop }
    end

    assert_redirected_to wb_berlin_path(assigns(:wb_berlin))
  end

  test "should show wb_berlin" do
    get :show, id: @wb_berlin
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wb_berlin
    assert_response :success
  end

  test "should update wb_berlin" do
    patch :update, id: @wb_berlin, wb_berlin: { band: @wb_berlin.band, seite_start: @wb_berlin.seite_start, seite_stop: @wb_berlin.seite_stop, uid: @wb_berlin.uid, wort_id: @wb_berlin.wort_id, zeile_start: @wb_berlin.zeile_start, zeile_stop: @wb_berlin.zeile_stop }
    assert_redirected_to wb_berlin_path(assigns(:wb_berlin))
  end

  test "should destroy wb_berlin" do
    assert_difference('Wbberlin.count', -1) do
      delete :destroy, id: @wb_berlin
    end

    assert_redirected_to wb_berlins_path
  end
end
