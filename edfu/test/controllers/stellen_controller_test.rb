require 'test_helper'

class StellenControllerTest < ActionController::TestCase
  setup do
    @stelle = stellen(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stellen)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stelle" do
    assert_difference('Stelle.count') do
      post :create, stelle: { band: @stelle.band, bandseite: @stelle.bandseite, bandseitezeile: @stelle.bandseitezeile, freigegeben: @stelle.freigegeben, seite_start: @stelle.seite_start, seite_stop: @stelle.seite_stop, start: @stelle.start, stelle_anmerkung: @stelle.stelle_anmerkung, stelle_unsicher: @stelle.stelle_unsicher, stop: @stelle.stop, tempel: @stelle.tempel, uid: @stelle.uid, zeile_start: @stelle.zeile_start, zeile_stop: @stelle.zeile_stop, zerstoerung: @stelle.zerstoerung }
    end

    assert_redirected_to stelle_path(assigns(:stelle))
  end

  test "should show stelle" do
    get :show, id: @stelle
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stelle
    assert_response :success
  end

  test "should update stelle" do
    patch :update, id: @stelle, stelle: { band: @stelle.band, bandseite: @stelle.bandseite, bandseitezeile: @stelle.bandseitezeile, freigegeben: @stelle.freigegeben, seite_start: @stelle.seite_start, seite_stop: @stelle.seite_stop, start: @stelle.start, stelle_anmerkung: @stelle.stelle_anmerkung, stelle_unsicher: @stelle.stelle_unsicher, stop: @stelle.stop, tempel: @stelle.tempel, uid: @stelle.uid, zeile_start: @stelle.zeile_start, zeile_stop: @stelle.zeile_stop, zerstoerung: @stelle.zerstoerung }
    assert_redirected_to stelle_path(assigns(:stelle))
  end

  test "should destroy stelle" do
    assert_difference('Stelle.count', -1) do
      delete :destroy, id: @stelle
    end

    assert_redirected_to stellen_path
  end
end
