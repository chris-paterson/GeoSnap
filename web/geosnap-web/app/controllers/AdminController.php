<?php
use Parse\ParseUser;
use Parse\ParseClient;
use Parse\ParseQuery;
use Parse\ParseObject;

class AdminController extends \BaseController {
	public function home() {
		$currentUser = ParseUser::getCurrentUser();
		$username = $currentUser->getUsername();

		return View::make('master', compact('username'));
	}

	/**
	 * Display a listing of the resource.
	 *
	 * @return Response
	 */
	public function index()
	{
		// Get reported items
		$query = new ParseQuery("Report");
		$reportedItems = $query->find();


		// php doesn't have sets so we must create one...
		$reportedComments = [];
		$reportedPosts = [];

		foreach ($reportedItems as $reportedItem) {
			$reportedClass = $reportedItem->get('class');
			$reportedId = $reportedItem->get('reportedItem');

			if ($reportedClass == "Comment") {
				if (!in_array($reportedId, $reportedComments)) {
					array_push($reportedComments ,$reportedId);
				}
			} else {
				if (!in_array($reportedId, $reportedPosts)) {
					array_push($reportedPosts, $reportedId);
				}
			}
		}

		$commentQuery = new ParseQuery("Comment");
		$commentQuery->containedIn("objectId", $reportedComments);
		$comments = $commentQuery->find();

		$postQuery = new ParseQuery("Post");
		$postQuery->containedIn("objectId", $reportedPosts);
		$posts = $postQuery->find();

		return View::make('admin.index', compact('comments', 'posts'));
	}

	public function deleteItem() {
		$objectInfo = Input::only('objectId', 'objectClass');

		$query = new ParseQuery($objectInfo['objectClass']);
		$objectToDestroy = $query->get($objectInfo['objectId']);
		$objectToDestroy->destroy();

		$this->removeAllFromReportTable($objectInfo['objectId']);
	}

	public function allowItem() {
		$objectInfo = Input::only('objectId');
		$this->removeAllFromReportTable($objectInfo['objectId']);
	}

	private function removeAllFromReportTable($objectId) {
		$query = new ParseQuery('Report');
		$query->equalTo('reportedItem', $objectId);
		$itemsToDestroy = $query->find();

		// Individually destroy each instance of report against the item as won't allow batch DELETE
		foreach ($itemsToDestroy as $item) {
			$item->destroy();
		}
	}

	/**
	 * Show the form for creating a new resource.
	 *
	 * @return Response
	 */
	public function create()
	{
		//
	}


	/**
	 * Store a newly created resource in storage.
	 *
	 * @return Response
	 */
	public function store()
	{
		//
	}


	/**
	 * Display the specified resource.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function show($id)
	{
		//
	}


	/**
	 * Show the form for editing the specified resource.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function edit($id)
	{
		//
	}


	/**
	 * Update the specified resource in storage.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function update($id)
	{
		//
	}


	/**
	 * Remove the specified resource from storage.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function destroy($id)
	{
		//
	}


}
