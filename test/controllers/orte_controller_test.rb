require 'test_helper'

class OrteControllerTest < ActionController::TestCase
  setup do
    @ort = orte(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orte)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ort" do
    assert_difference('Ort.count') do
      post :create, ort: { anmerkung: @ort.anmerkung, lokalisation: @ort.lokalisation, ort: @ort.ort, stelle: @ort.stelle, transliteration: @ort.transliteration, transliteration_nosuffix: @ort.transliteration, uid: @ort.uid }
    end

    assert_redirected_to ort_path(assigns(:ort))
  end

  test "should show ort" do
    get :show, id: @ort
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ort
    assert_response :success
  end

  test "should update ort" do
    patch :update, id: @ort, ort: { anmerkung: @ort.anmerkung, lokalisation: @ort.lokalisation, ort: @ort.ort, stelle: @ort.stelle, transliteration: @ort.transliteration, transliteration_nosuffix: @ort.transliteration, uid: @ort.uid }
    assert_redirected_to ort_path(assigns(:ort))
  end

  test "should destroy ort" do
    assert_difference('Ort.count', -1) do
      delete :destroy, id: @ort
    end

    assert_redirected_to orte_path
  end
end
