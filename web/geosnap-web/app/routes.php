<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the Closure to execute when that URI is requested.
|
*/
use Parse\ParseObject;
Parse\ParseClient::initialize('yRxNdukOZCMQD9jRrxRMevl6mlEy8uA0M9TgAvmF', 
        'mEmX6ZTOkZj2pfsN0nb8ZQNnUjWkFGuQSKNsqJjm', 
        'VlJkPaGucGAyN9SarlnZF55yd6pd6SfCkeLC1oOD');

Route::get('/', function() {
    // $app_id, $rest_key, $master_key
    

    $testObject = ParseObject::create("TestObject");
    $testObject->set("foo", "bar");
    $testObject->save();

	return View::make('master');
});


Route::get('login', array(
    'as' => 'login',
    'uses' => 'UserController@login'
));

Route::post('login', function () {
    if (Auth::attempt(Input::only('username', 'password'))) {
        return View::make('master');
    } else {
        return Redirect::route('login')
            ->withInput();
    }
});