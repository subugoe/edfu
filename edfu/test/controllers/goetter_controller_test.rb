require 'test_helper'

class GoetterControllerTest < ActionController::TestCase
  setup do
    @gott = goetter(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:goetter)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gott" do
    assert_difference('Gott.count') do
      post :create, gott: { anmerkung: @gott.anmerkung, band: @gott.band, beziehung: @gott.beziehung, eponym: @gott.eponym, funktion: @gott.funktion, ort: @gott.ort, seitenzeile: @gott.seitenzeile, transliteration: @gott.transliteration, transliteration_nosuffix: @gott.transliteration_nosuffix, uid: @gott.uid }
    end

    assert_redirected_to gott_path(assigns(:gott))
  end

  test "should show gott" do
    get :show, id: @gott
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gott
    assert_response :success
  end

  test "should update gott" do
    patch :update, id: @gott, gott: { anmerkung: @gott.anmerkung, band: @gott.band, beziehung: @gott.beziehung, eponym: @gott.eponym, funktion: @gott.funktion, ort: @gott.ort, seitenzeile: @gott.seitenzeile, transliteration: @gott.transliteration, transliteration_nosuffix: @gott.transliteration_nosuffix, uid: @gott.uid }
    assert_redirected_to gott_path(assigns(:gott))
  end

  test "should destroy gott" do
    assert_difference('Gott.count', -1) do
      delete :destroy, id: @gott
    end

    assert_redirected_to goetter_path
  end
end
