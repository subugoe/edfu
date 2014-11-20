require 'test_helper'

class FormulareControllerTest < ActionController::TestCase
  setup do
    @formular = formulare(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:formulare)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create formular" do
    assert_difference('Formular.count') do
      post :create, formular: { band: @formular.band, literatur: @formular.literatur, photo: @formular.photo, photo_kommentar: @formular.photo_kommentar, photo_pfad: @formular.photo_pfad, seitenzeile: @formular.seitenzeile, szeneID: @formular.szeneID, texttyp: @formular.texttyp, transliteration: @formular.transliteration, transliteration_nosuffix: @formular.transliteration_nosuffix, uebersetzung: @formular.uebersetzung, uid: @formular.uid }
    end

    assert_redirected_to formular_path(assigns(:formular))
  end

  test "should show formular" do
    get :show, id: @formular
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @formular
    assert_response :success
  end

  test "should update formular" do
    patch :update, id: @formular, formular: { band: @formular.band, literatur: @formular.literatur, photo: @formular.photo, photo_kommentar: @formular.photo_kommentar, photo_pfad: @formular.photo_pfad, seitenzeile: @formular.seitenzeile, szeneID: @formular.szeneID, texttyp: @formular.texttyp, transliteration: @formular.transliteration, transliteration_nosuffix: @formular.transliteration_nosuffix, uebersetzung: @formular.uebersetzung, uid: @formular.uid }
    assert_redirected_to formular_path(assigns(:formular))
  end

  test "should destroy formular" do
    assert_difference('Formular.count', -1) do
      delete :destroy, id: @formular
    end

    assert_redirected_to formulare_path
  end
end
