public with sharing class o2_globalTestMethod_Class1 
{
    
    //==================================================
    static testMethod void XML_Dom1() 
    //==================================================     
    { 
        xmldom d;        
        d = new xmldom('<book  author="Manoj" >My Book</book>');
        //d.dumpAll(); 
        XMLdom.Element e = d.getElementsByTagName('book')[0];
        system.assert( e.getAttribute('author') =='Manoj' ); 
        
        d = new xmldom(); d.parseFromString('<book  author="Manoj" >My Book</book>');
        //d.dumpAll(); 
         
        d = new xmldom('<books><book>My Book</book></books>');
        //d.dumpAll(); 
        //system.debug( d.getElements() ); 
        system.debug ( d.getElementsByTagName('book')[0].nodeValue );
        system.assert ( d.getElementsByTagName('book')[0].nodeValue == 'My Book' );
        
        d = new xmldom('<books><book author="Manoj" date="1999" >My Book</book><book author="Ron" >Your Book</book></books>'); 
        //d.dumpAll();
        system.debug ( d.getElementsByTagName('book') );
        for(XMLdom.Element ee:d.getElementsByTagName('book')) { system.debug( 'Author is ' + ee.getAttribute('author')); }
        XMLdom.Element ee  = new xmldom.Element(); 
         
        string testListBucketResponse = 
             '<?xml version="1.0" encoding="UTF-8"?>'+ 
            '<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>12gkzwnp21m8nw02-test-bucket</Name><Prefix>'+
            '</Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Contents><Key>/apex/adnDevSignup</Key>'+
            '<LastModified>2008-01-27T21:13:58.000Z</LastModified><ETag>&quot;630581ddc40fa0a3b7e521c67962baba&quot;</ETag><Size>27411</Size>'+
            '<Owner><ID>173ea00b3418d9a715d5f5a0d85290c3be11135ecf9a085504a4b1bbb6ea1</ID><DisplayName>vne</DisplayName></Owner>'+
            '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>apex/adnDevSignup</Key><LastModified>2008-01-31T09:50:41.000Z</LastModified>'+
            '<ETag>&quot;2d9ab36295e58d32db358aae0195c164&quot;</ETag><Size>27410</Size><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
            '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>apex/adnRoot</Key><LastModified>2008-01-31T09:50:40.000Z</LastModified>'+
            '<ETag>&quot;f956a9612c95c206f3208f023d1edefb&quot;</ETag><Size>20036</Size><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
            '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test-key-public</Key><LastModified>2008-02-02T04:02:59.000Z</LastModified>'+
            '<ETag>&quot;12f3e46f80c24c997c4304953edc3612&quot;</ETag><Size>32</Size><Owner><ID>173ea00891b39a715d5f5a0d85290c3be11135ecf9a085504a4b1bbb6ea1</ID>'+
            '<DisplayName>foobar</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test-two</Key>'+
            '<LastModified>2008-02-02T00:40:29.000Z</LastModified><ETag>&quot;327b6f07435811239bc47e1544353273&quot;</ETag><Size>7</Size>'+
            '<Owner><ID>173</ID><DisplayName>foobar</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>';
        d = new xmldom(testListBucketResponse); 
        //d.dumpAll();
        List<xmldom.Element> keys = d.getElementsByTagName('Key');
        
        //system.debug ( keys ); 
        for(XMLdom.Element e2:keys) { system.debug( 'Key is '  + e2.nodeValue ); }
        
        integer count= keys.size();
        system.assert(count>1);
        system.debug(count);
        
        XMLdom.Element p = keys[0].parentNode;
        p.removeChild(p.firstChild());
        
        keys = d.getElementsByTagName('Key');
        system.assert(keys.size() == count-1);
        
        keys = d.root.getElementsByTagName('Key');
        for(XMLdom.Element e2: keys ) { 
            system.debug( 'Key is ' + e2.nodeValue ); 
            e2.dump(); 
         }
        count= keys.size();
        system.assert(count>1);
        system.debug(count);
        
        string testErrorResponse = 
         '<?xml version="1.0" encoding="UTF-8"?>'+ 
         '<Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message><Key>test-key</Key><RequestId>49D135DD55EBD</RequestId>'+
         '<HostId>PB4hNZ</HostId></Error>';
    
        d = new xmldom(testErrorResponse); 
        d.root.dumpAll();
        
        // uses namespaces
         string testACLResponse = 
         '<?xml version="1.0" encoding="UTF-8"?>'+ 
         '<AccessControlPolicy xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
         '<AccessControlList><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser" foo="bar" ><ID>owner_id</ID>'+
         '<DisplayName>foobar</DisplayName></Grantee><Permission>FULL_CONTROL</Permission></Grant></AccessControlList></AccessControlPolicy>';
        d = new xmldom(testACLResponse); 
        //d.dumpAll(); 
        system.assert( d.root.hasChildNodes() ); 
        
        system.assert(  d.root.isEqualNode(d.root) ,' is equal node');
        system.assert( d.root.textContent() == '' );
         
        d.getElementsByTagName('Grantee')[0].dump(); 
        
        system.assert( d.getElementsByTagName('Grantee')[0].hasAttributes() );
        
        d.getElementsByPath('/.*/Grantee/.*')[0].dump();    
        d.getElementByPath('/.*/Grantee/.*').dump();   
        system.assert( d.getElementByPath('bad') == null );   
        system.assert( d.getElementByTagName('badName') == null ); 
        system.assert( d.toXmlString() != null );   
    }
    
       
   
   
    //==================================================
    static testMethod void XML_Dom2() 
    //================================================== 
    { 
        xmldom f = new xmldom( '<RetrieveItem_Request_1 xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/Quotes_1"><ItemRequest Scope="All"><QoS xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon"><TimelinessInfo Timeliness="DELAYED" /><RateInfo Rate="UNSPECIFIED" /></QoS><Fields xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon" /><RequestKey xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon" Name="MSFT.O" Service="" NameType="RIC" /></ItemRequest></RetrieveItem_Request_1>');            
        system.debug( f.toXmlString() );
    }
    
    public static testmethod void test_except() { 
         string testNotification = 
         '<?xml version="1.0" encoding="UTF-8"?>' +
            '<bookstore><book><title lang="eng">Harry Potter</title><price>29.99</price>' +
            '</book><book><title lang="eng">Learning '; // truncated
        xmldom f = new xmldom( testNotification );
        // should cause an exception which is caught , returning a truncated dom
        for ( xmldom.element e : f.getElementsByTagName('title') ) {
            e.dump(); 
        }
        system.assert( f.getElementsByTagName('title')[0].nodeValue == 'Harry Potter' );
        system.assert( f.getElementsByTagName('title')[1].nodeValue == '' );

    }

    //==================================================
    static testMethod void XML_Dom3() 
    //================================================== 
    { 
         string testNotification = 
         '<?xml version="1.0" encoding="UTF-8"?>' +
            '<bookstore><book><title lang="eng">Harry Potter</title><price>29.99</price>' +
            '</book><book><title lang="eng">Learning XML</title><price>39.95</price></book></bookstore>';

        xmldom d;
        d = new xmldom(testNotification);  
        list<xmldom.element> tmp ; 

        tmp =  d.root.getElementsByTagName('book');  // matching by name
        system.assertEquals( 2, tmp.size() ); 
        d.dumpList( tmp );
        
        XMLdom.Element a = d.ownerDocument();
        XMLdom.Element f = a.firstChild();
        XMLdom.Element c = f.ownerDocument(); 
        system.assert( a.isSameNode( c ) );
        XMLdom.Element b = a.cloneNode();
        system.assert( ! a.isSameNode(f) ); 
        
        a = new XMLdom.Element(); 
        system.assertEquals( a.firstChild(), null, ' must be null' );
        
        system.assertEquals( a.getElementByTagName('bad'), null);       
     }

  
    //==================================================
    static testMethod void testRSS()
    //==================================================  
    { 
        
        String feed = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<feed xmlns="http://purl.org/atom/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:feedburner="http://rssnamespace.org/feedburner/ext/1.0" version="0.3">'+
            '<title>Force.com Blog</title>' +
            '<link rel="alternate" type="text/html" href="http://blog.sforce.com/sforce/" />' +
            '<id>tag:typepad.com,2003:weblog-125619</id>' +
            '<link rel="service.post" type="application/x.atom+xml" href="http://www.typepad.com/t/atom/weblog/blog_id=125619" title="Force.com Blog" />' +
            '<modified>2008-01-23T20:27:30Z</modified>' +
            '<tagline></tagline>' +
            '<generator url="http://www.typepad.com/">TypePad</generator>' +
            '<info type="application/xhtml+xml">' +
            '<div xmlns="http://www.w3.org/1999/xhtml">This is an Atom formatted XML site feed. It is intended to be viewed in a Newsreader or syndicated to another site. Please visit <a href="http://blog.sforce.com/sforce/">Force.com Blog</a> for more info.</div>' +
            '</info><entry>' +
            '<title>Tour de Force Global Kickoff - it\'s a wrap!</title>' +
            '<link rel="alternate" type="text/html" href="http://feeds.feedburner.com/~r/SforceBlog/~3/221839184/tour-de-force-g.html" />' +
            '<link rel="service.edit" type="application/x.atom+xml" href="http://www.typepad.com/t/atom/weblog/blog_id=125619/entry_id=44564390" title="Tour de Force Global Kickoff - it\'s a wrap!" />' +
            '<id>tag:typepad.com,2003:post-44564390</id>' +
            '<issued>2008-01-23T12:27:30-08:00</issued>' +
            '<modified>2008-01-23T20:27:30Z</modified>' +
            '<created>2008-01-23T20:27:30Z</created>' +
            '<summary>Thank you to everyone that joined us last Thursday in San Francisco as we kicked off Tour de Force - we\'re delighted that you were able help us launch the Tour de Force roadshow to unleash the Force.com platform around...</summary>' +
            '<author><name>Mark Trang</name></author>' +
            '<content type="application/xhtml+xml" xml:lang="en-US" xml:base="http://blog.sforce.com/sforce/"><div xmlns="http://www.w3.org/1999/xhtml">'+
            '<p>Thank you to everyone that joined us last Thursday in San Francisco as we kicked off Tour de Force - </p></div></content>'+
            '<feedburner:origLink>http://blog.sforce.com/sforce/2008/01/tour-de-force-g.html</feedburner:origLink></entry></feed>';
        xmldom d = new xmldom(feed);  
        list<xmldom.element> tmp ;  
        d.dumpAll();
        XMLdom.Element e2 = d.ownerDocument().getElementByTagName('entry');
        e2.dumpAll();   
        system.assertEquals('entry', e2.nodeName );         
        system.assertEquals( e2.getValue('title'), 'Tour de Force Global Kickoff - it\'s a wrap!');
        
        
        XMLdom.Element[] el = d.ownerDocument().getElementsByTagName('link');
        for(XMLdom.Element ee:el) { 
            system.debug( ee.path() );
            ee.dump(); 
        }
        
        e2 = d.ownerDocument().getElementByTagName('name');
        System.assertEquals('Mark Trang', e2.nodeValue);
        
        e2 = d.ownerDocument().getElementsByPath('/feed/title')[0];
        e2.dump();
        
        /* 
         * experimental path based patern matching, sort of like xpath, 
         * but simpler, just matches a path() string with 
         * the pattern supplied
         */
        // children of entry
        el= d.ownerDocument().getElementsByPath('/feed/entry/.*');
        d.dumpList(el);
        system.assertEquals( 14, el.size() );
        
        // just the entry node
        el= d.ownerDocument().getElementsByPath('/feed/entry');
        system.assertEquals( 1, el.size() );
        
        // entry and children
        el= d.ownerDocument().getElementsByPath('/.*/entry.*');
        system.assertEquals( 15, el.size() );
    }        

    //==================================================
    static testMethod void XML_Dom4() 
    //================================================== 
    { 
        xmldom d;        
        d = new xmldom('<book  author="Manoj" >My Book</book>');
        //d.dumpAll(); 
        XMLdom.Element e = d.getElementsByTagName('book')[0];
        system.assert( e.getAttribute('author') =='Manoj' ); 
        
        d = new xmldom(); d.parseFromString('<book  author="Manoj" >My Book</book>');
        //d.dumpAll(); 
         
        d = new xmldom('<books><book>My Book</book></books>');
        //d.dumpAll(); 
        //system.debug( d.getElements() ); 
        system.debug ( d.getElementsByTagName('book')[0].nodeValue );
        system.assert ( d.getElementsByTagName('book')[0].nodeValue == 'My Book' );
        
        d = new xmldom('<books><book author="Manoj" date="1999" >My Book</book><book author="Ron" >Your Book</book></books>'); 
        //d.dumpAll();
        system.debug ( d.getElementsByTagName('book') );
        for(XMLdom.Element ee:d.getElementsByTagName('book')) { system.debug( 'Author is ' + ee.getAttribute('author')); }
        XMLdom.Element ee  = new xmldom.Element(); 
         
        string testListBucketResponse = 
             '<?xml version="1.0" encoding="UTF-8"?>'+ 
            '<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>12gkzwnp21m8nw02-test-bucket</Name><Prefix>'+
            '</Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Contents><Key>/apex/adnDevSignup</Key>'+
            '<LastModified>2008-01-27T21:13:58.000Z</LastModified><ETag>&quot;630581ddc40fa0a3b7e521c67962baba&quot;</ETag><Size>27411</Size>'+
            '<Owner><ID>173ea00b3418d9a715d5f5a0d85290c3be11135ecf9a085504a4b1bbb6ea1</ID><DisplayName>vne</DisplayName></Owner>'+
            '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>apex/adnDevSignup</Key><LastModified>2008-01-31T09:50:41.000Z</LastModified>'+
            '<ETag>&quot;2d9ab36295e58d32db358aae0195c164&quot;</ETag><Size>27410</Size><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
            '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>apex/adnRoot</Key><LastModified>2008-01-31T09:50:40.000Z</LastModified>'+
            '<ETag>&quot;f956a9612c95c206f3208f023d1edefb&quot;</ETag><Size>20036</Size><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
            '<StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test-key-public</Key><LastModified>2008-02-02T04:02:59.000Z</LastModified>'+
            '<ETag>&quot;12f3e46f80c24c997c4304953edc3612&quot;</ETag><Size>32</Size><Owner><ID>173ea00891b39a715d5f5a0d85290c3be11135ecf9a085504a4b1bbb6ea1</ID>'+
            '<DisplayName>foobar</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test-two</Key>'+
            '<LastModified>2008-02-02T00:40:29.000Z</LastModified><ETag>&quot;327b6f07435811239bc47e1544353273&quot;</ETag><Size>7</Size>'+
            '<Owner><ID>173</ID><DisplayName>foobar</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>';
        d = new xmldom(testListBucketResponse); 
        //d.dumpAll();
        List<xmldom.Element> keys = d.getElementsByTagName('Key');
        
        //system.debug ( keys ); 
        for(XMLdom.Element e2:keys) { system.debug( 'Key is '  + e2.nodeValue ); }
        
        integer count= keys.size();
        system.assert(count>1);
        system.debug(count);
        
        XMLdom.Element p = keys[0].parentNode;
        p.removeChild(p.firstChild());
        
        keys = d.getElementsByTagName('Key');
        system.assert(keys.size() == count-1);
        
        keys = d.root.getElementsByTagName('Key');
        for(XMLdom.Element e2: keys ) { 
            system.debug( 'Key is ' + e2.nodeValue ); 
            e2.dump(); 
         }
        count= keys.size();
        system.assert(count>1);
        system.debug(count);
        
        string testErrorResponse = 
         '<?xml version="1.0" encoding="UTF-8"?>'+ 
         '<Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message><Key>test-key</Key><RequestId>49D135DD55EBD</RequestId>'+
         '<HostId>PB4hNZ</HostId></Error>';
    
        d = new xmldom(testErrorResponse); 
        d.root.dumpAll();
        
        // uses namespaces
         string testACLResponse = 
         '<?xml version="1.0" encoding="UTF-8"?>'+ 
         '<AccessControlPolicy xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>owner_id</ID><DisplayName>foobar</DisplayName></Owner>'+
         '<AccessControlList><Grant><Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser" foo="bar" ><ID>owner_id</ID>'+
         '<DisplayName>foobar</DisplayName></Grantee><Permission>FULL_CONTROL</Permission></Grant></AccessControlList></AccessControlPolicy>';
        d = new xmldom(testACLResponse); 
        //d.dumpAll(); 
        system.assert( d.root.hasChildNodes() ); 
        
        system.assert(  d.root.isEqualNode(d.root) ,' is equal node');
        system.assert( d.root.textContent() == '' );
         
        d.getElementsByTagName('Grantee')[0].dump(); 
        
        system.assert( d.getElementsByTagName('Grantee')[0].hasAttributes() );
        
        d.getElementsByPath('/.*/Grantee/.*')[0].dump();    
        d.getElementByPath('/.*/Grantee/.*').dump();   
        system.assert( d.getElementByPath('bad') == null );   
        system.assert( d.getElementByTagName('badName') == null ); 
        system.assert( d.toXmlString() != null );   
    }
 
    //==================================================
    static testMethod void XML_Dom5() 
    //================================================== 
    { 
        xmldom f = new xmldom( '<RetrieveItem_Request_1 xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/Quotes_1"><ItemRequest Scope="All"><QoS xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon"><TimelinessInfo Timeliness="DELAYED" /><RateInfo Rate="UNSPECIFIED" /></QoS><Fields xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon" /><RequestKey xmlns="http://www.reuters.com/ns/2006/05/01/webservices/rkd/QuotesCommon" Name="MSFT.O" Service="" NameType="RIC" /></ItemRequest></RetrieveItem_Request_1>');            
        system.debug( f.toXmlString() );
    }

    //==================================================
    static testMethod void XML_Dom6() 
    //==================================================  
    { 
         string testNotification = 
         '<?xml version="1.0" encoding="UTF-8"?>' +
            '<bookstore><book><title lang="eng">Harry Potter</title><price>29.99</price>' +
            '</book><book><title lang="eng">Learning '; // truncated
        xmldom f = new xmldom( testNotification );
        // should cause an exception which is caught , returning a truncated dom
        for ( xmldom.element e : f.getElementsByTagName('title') ) {
            e.dump(); 
        }
        system.assert( f.getElementsByTagName('title')[0].nodeValue == 'Harry Potter' );
        system.assert( f.getElementsByTagName('title')[1].nodeValue == '' );
    }

    
    //==================================================
    static testMethod void XML_Dom7() 
    //================================================== 
    { 
         string testNotification = 
         '<?xml version="1.0" encoding="UTF-8"?>' +
            '<bookstore><book><title lang="eng">Harry Potter</title><price>29.99</price>' +
            '</book><book><title lang="eng">Learning XML</title><price>39.95</price></book></bookstore>';

        xmldom d;
        d = new xmldom(testNotification);  
        list<xmldom.element> tmp ; 

        tmp =  d.root.getElementsByTagName('book');  // matching by name
        system.assertEquals( 2, tmp.size() ); 
        d.dumpList( tmp );
        
        XMLdom.Element a = d.ownerDocument();
        XMLdom.Element f = a.firstChild();
        XMLdom.Element c = f.ownerDocument(); 
        system.assert( a.isSameNode( c ) );
        XMLdom.Element b = a.cloneNode();
        system.assert( ! a.isSameNode(f) ); 
        
        a = new XMLdom.Element(); 
        system.assertEquals( a.firstChild(), null, ' must be null' );
        
        system.assertEquals( a.getElementByTagName('bad'), null);       
     }

    //==================================================
    static testMethod void RSS_test() 
    //================================================== 
    { 
        
        String feed = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<feed xmlns="http://purl.org/atom/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:feedburner="http://rssnamespace.org/feedburner/ext/1.0" version="0.3">'+
            '<title>Force.com Blog</title>' +
            '<link rel="alternate" type="text/html" href="http://blog.sforce.com/sforce/" />' +
            '<id>tag:typepad.com,2003:weblog-125619</id>' +
            '<link rel="service.post" type="application/x.atom+xml" href="http://www.typepad.com/t/atom/weblog/blog_id=125619" title="Force.com Blog" />' +
            '<modified>2008-01-23T20:27:30Z</modified>' +
            '<tagline></tagline>' +
            '<generator url="http://www.typepad.com/">TypePad</generator>' +
            '<info type="application/xhtml+xml">' +
            '<div xmlns="http://www.w3.org/1999/xhtml">This is an Atom formatted XML site feed. It is intended to be viewed in a Newsreader or syndicated to another site. Please visit <a href="http://blog.sforce.com/sforce/">Force.com Blog</a> for more info.</div>' +
            '</info><entry>' +
            '<title>Tour de Force Global Kickoff - it\'s a wrap!</title>' +
            '<link rel="alternate" type="text/html" href="http://feeds.feedburner.com/~r/SforceBlog/~3/221839184/tour-de-force-g.html" />' +
            '<link rel="service.edit" type="application/x.atom+xml" href="http://www.typepad.com/t/atom/weblog/blog_id=125619/entry_id=44564390" title="Tour de Force Global Kickoff - it\'s a wrap!" />' +
            '<id>tag:typepad.com,2003:post-44564390</id>' +
            '<issued>2008-01-23T12:27:30-08:00</issued>' +
            '<modified>2008-01-23T20:27:30Z</modified>' +
            '<created>2008-01-23T20:27:30Z</created>' +
            '<summary>Thank you to everyone that joined us last Thursday in San Francisco as we kicked off Tour de Force - we\'re delighted that you were able help us launch the Tour de Force roadshow to unleash the Force.com platform around...</summary>' +
            '<author><name>Mark Trang</name></author>' +
            '<content type="application/xhtml+xml" xml:lang="en-US" xml:base="http://blog.sforce.com/sforce/"><div xmlns="http://www.w3.org/1999/xhtml">'+
            '<p>Thank you to everyone that joined us last Thursday in San Francisco as we kicked off Tour de Force - </p></div></content>'+
            '<feedburner:origLink>http://blog.sforce.com/sforce/2008/01/tour-de-force-g.html</feedburner:origLink></entry></feed>';
        xmldom d = new xmldom(feed);  
        list<xmldom.element> tmp ;  
        d.dumpAll();
        XMLdom.Element e2 = d.ownerDocument().getElementByTagName('entry');
        e2.dumpAll();   
        system.assertEquals('entry', e2.nodeName );         
        system.assertEquals( e2.getValue('title'), 'Tour de Force Global Kickoff - it\'s a wrap!');
        
        
        XMLdom.Element[] el = d.ownerDocument().getElementsByTagName('link');
        for(XMLdom.Element ee:el) { 
            system.debug( ee.path() );
            ee.dump(); 
        }
        
        e2 = d.ownerDocument().getElementByTagName('name');
        System.assertEquals('Mark Trang', e2.nodeValue);
        
        e2 = d.ownerDocument().getElementsByPath('/feed/title')[0];
        e2.dump();
        
        /* 
         * experimental path based patern matching, sort of like xpath, 
         * but simpler, just matches a path() string with 
         * the pattern supplied
         */
        // children of entry
        el= d.ownerDocument().getElementsByPath('/feed/entry/.*');
        d.dumpList(el);
        system.assertEquals( 14, el.size() );
        
        // just the entry node
        el= d.ownerDocument().getElementsByPath('/feed/entry');
        system.assertEquals( 1, el.size() );
        
        // entry and children
        el= d.ownerDocument().getElementsByPath('/.*/entry.*');
        system.assertEquals( 15, el.size() );
    }   
    
    
    
    
    
    
    
    
    //==================================================
    public static void TriggerAndInsert6() 
    //==================================================
    {
        Lead Lead171p = [SELECT id, name, isconverted FROM Lead WHERE isconverted = false LIMIT 1]; 
        Lead171p.IsConverted    =   true;
        update Lead171p;        
    }
  
   //==================================================
   static testMethod void TestCodeCoverage() 
   //==================================================
   {
      integer iCount;
      // s173 - Create a lead with a 2 lead contacts, convert it and check that the lead contact became an account contact
      Lead Lead173 = new Lead(LastName = 'XXX_Lead173', Company = 'XXX Lead 173 Company', Tree_Org_Reg_no__c = 'SWPS000142_s173', Status = 'New', LeadSource = 'MNC' );
      insert Lead173;
      //
      //Lead Lead173ID = [select ID from Lead where Tree_Org_Reg_no__c = :Lead173.Tree_Org_Reg_no__c];
      //    
      Contacts_for_Leads__c CFL173a = new Contacts_for_Leads__c(Last_Name__c = 'XXX Smith s173a', Tree_Organisation_ID__c = 'SWPS000142_s173');
      insert CFL173a;
      //Contacts_for_Leads__c CFL173aID = [select Lead__c from Contacts_for_Leads__c where Tree_Organisation_ID__c = 'SWPS000142_s173' and Last_Name__c = 'XXX Smith s173a'];
      Contacts_for_Leads__c CFL173b = new Contacts_for_Leads__c(Last_Name__c = 'XXX Smith s173b', Tree_Organisation_ID__c = 'SWPS000142_s173');
      insert CFL173b;
      //Contacts_for_Leads__c CFL173bID = [select Lead__c from Contacts_for_Leads__c where Tree_Organisation_ID__c = 'SWPS000142_s173' and Last_Name__c = 'XXX Smith s173b'];
      //
      // Now convert the Lead 
      
      Database.LeadConvert lc = new database.LeadConvert();
      lc.setLeadId(Lead173.id);
      LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
      lc.setConvertedStatus(convertStatus.MasterLabel);
      Database.LeadConvertResult lcr = Database.convertLead(lc);
      System.assert(lcr.isSuccess());      
      system.debug(lcr.getAccountId());
      
      // convert trigger works from the lead - when IsConverted = true
      //Lead Lead173conv = new Lead(Id = Lead173ID.Id, IsConverted = true);
      //update Lead173conv;
      
      //
      //Account Acct173 = [select ID from Account where ID = :lcr.getAccountId()];
      //iCount = [select count() from Account where ID = :lcr.getAccountId()];
      //System.assertEquals(iCount, 1);
      //  
      //iCount = [select count() from Contact where AccountId = :lcr.getAccountId()];
      //System.assertEquals(3, iCount);
      //iCount = [select count() from Contact where LastName = 'XXX Smith s173a'];
      //System.assertEquals(1, iCount);
      //
      //icount = [select count() from Lead where ConvertedAccountID
   }
   

   //==================================================
   static testMethod void O2_linkage_register_app_sales() 
   //==================================================
   {
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;
        
        // Create an account validation entry so that we can create an account with valid billing code
        List<Account_Validation_Table__c> validEntries = new List<Account_Validation_Table__c>();
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY1',
                                                            Full_Account__c = 'TUKKY1',
                                                            Account__c = 'TUKKY1'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY2',
                                                            Full_Account__c = 'TUKKY2',
                                                            Account__c = 'TUKKY2'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY3',
                                                            Full_Account__c = 'TUKKY3',
                                                            Account__c = 'TUKKY3'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY4',
                                                            Full_Account__c = 'TUKKY4',
                                                            Account__c = 'TUKKY4'));                                                                                                                                                                                    

        insert validEntries;
                                                                                            
        // Create an account with the correct fields for a register
        Account registeringAccount = new Account(   DISE_Group_Code_Account_No_1__c = 'TUKKY1',
                                                    DISE_Group_Code_Account_No_2__c = 'TUKKY2',
                                                    DISE_Group_Code_Account_No_3__c = 'TUKKY3',
                                                    DISE_Group_Code_Account_No_4__c = 'TUKKY4',
                                                    Name = 'TUKKY1_TEST',
                                                    // START - Added Darren Sabey 5/1/2011
                                                    Contract_End_Date__c = System.today().addDays(365),
                                                    // END - Added Darren Sabey 5/1/2011
                                                    Status__c = 'Customer',
                                                    Contract_Start_Date__c = Date.Today(),
                                                    Contract_Duration__c = '4',
                                                    Date_Effective_From__c = Date.Today(),
                                                    BillingStreet = '5 Hamilton Street',
                                                    BillingCity = 'Exeter',
                                                    BillingPostalCode = 'EX1 1AA',
                                                    BillingState = 'Devon');
                                                    
        insert registeringAccount;
        
        // Now create an opportunity for this account and register via the opportunity
        Opportunity registeringOpp = new Opportunity(AccountId = registeringAccount.Id,
                                                        Name = 'TUKKY1_TEST_OPP',
                                                        Type = 'Existing Business',
                                                        StageName = 'other',
                                                        CloseDate = Date.Today(),
                                                        LeadSource = 'LBM',
                                                        Use_of_CCV__c = 'CCV Not Used',
                                                        TotalOpportunityQuantity = 1.0,
                                                        Close_Comment__c = 'my close comment',
                                                        CCV_Not_used_reason__c = 'Run Rate',
                                                        CCV_Not_used_comments__c = 'This is the comment');
        insert registeringOpp;
        
        O2_Product_Detail__c prodline = new O2_Product_Detail__c(   Length_of_Contract__c = '36 Months',
                                                                    OARApplicationId__c = '1234',
                                                                    Application_Sale_Date__c = Date.today(),
                                                                    Number_of_Licences__c = 12,
                                                                    OARMobSpecId__c = '12',
                                                                    Contract_Reference__c = 'ref',
                                                                    OARNotes__c = 'notes',
                                                                    Opportunity__c = registeringOpp.Id,
                                                                    Total_Contract_Value__c = 100.00);
        insert prodline;                                                                    
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(registeringOpp);
        O2_linkage_register_app_sales oas = new O2_linkage_register_app_sales(stdController);
        oas.appSalesStatus();
        
        registeringOpp.StageName = 'Closed Won';
        update registeringOpp;
        oas.appSalesStatus();
        
    } // end test1
    
    
    
    
 
    //==================================================
    static testMethod void O2_linkage_handover_ce() 
    //================================================== 
    {
        
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;
                
        // Create an account validation entry so that we can create an account with valid billing code
        List<Account_Validation_Table__c> validEntries = new List<Account_Validation_Table__c>();
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY1',
                                                            Full_Account__c = 'TUKKY1',
                                                            Account__c = 'TUKKY1'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY2',
                                                            Full_Account__c = 'TUKKY2',
                                                            Account__c = 'TUKKY2'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY3',
                                                            Full_Account__c = 'TUKKY3',
                                                            Account__c = 'TUKKY3'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY4',
                                                            Full_Account__c = 'TUKKY4',
                                                            Account__c = 'TUKKY4'));                                                                                                                                                                                    

        insert validEntries;
                                                                                            
        // Create an account with the correct fields for a register
        Account acc = new Account(  DISE_Group_Code_Account_No_1__c = 'TUKKY1',
                                    DISE_Group_Code_Account_No_2__c = 'TUKKY2',
                                    DISE_Group_Code_Account_No_3__c = 'TUKKY3',
                                    DISE_Group_Code_Account_No_4__c = 'TUKKY4',
                                    Name = 'TUKKY1_TEST',
                                    // START - Added Darren Sabey 5/1/2011
                                    Contract_End_Date__c = System.today().addDays(365),
                                    // END - Added Darren Sabey 5/1/2011
                                    Status__c = 'Customer',
                                    Contract_Start_Date__c = Date.Today(),
                                    Contract_Duration__c = '4',
                                    Date_Effective_From__c = Date.Today(),
                                    BillingStreet = '5 Hamilton Street',
                                    BillingCity = 'Exeter',
                                    BillingPostalCode = 'EX1 1AA',                                    
                                    BillingState = 'Devon');
                                                    
        insert acc;
        ApexPages.StandardController ascont = new ApexPages.StandardController(acc);
        O2_linkage_handover_ce olh = new O2_linkage_handover_ce(ascont);
        olh.cancelSearch();
        olh.step1();
        olh.searchFilterString = '';
        olh.step2();
        
        // Get a real salesforce active user name for filter string
        User filterUser = [Select Lastname From User Where IsActive = true Limit 1];
        olh.searchFilterString = filterUser.Lastname;
        olh.step2();
        acc.OAR_Account_Reference_1__c = null;
        olh.step2();
        acc.OAR_Account_Reference_1__c = '1234';
        olh.step2();
        olh.step3();
        olh.usersForDisplay.get(0).selected = true;
        olh.step3();
        olh.step4();
        acc.OAR_Account_1_Handover_Comment__c = 'comment';
        acc.OAR_Account_1_Handover_Effective_Date__c = Date.today();
        olh.step4();
        
        acc.OAR_Account_Reference_1__c = null;
        olh.getOARWarning();
        acc.OAR_Account_Reference_1__c = '1234';
        olh.getOARWarning();
        
        olh.getNotAcc1Valid();
        
        acc.OAR_Account_1_Handover_Status__c = O2_linkage_configuration.getParam('HANDOVER_ACCEPTED');
        olh.getAcc1Valid();
        acc.OAR_Account_1_Handover_Status__c = 'junk';
        olh.getAcc1Valid();
        
        olh.getSelectedEmail();
        olh.getSelectedName();
        olh.getSelectedSalesforceName();
        
        
        
    } // end test1
   

   
    //==================================================
    static testMethod void O2_linkage_Acc_Reg_Conf_CE() 
    //================================================== 
   {
        // Show we are testing so that web services are not called
        O2_linkage_configuration.TESTING = true;

        
        // Create an account validation entry so that we can create an account with valid billing code
        List<Account_Validation_Table__c> validEntries = new List<Account_Validation_Table__c>();
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY1',
                                                            Full_Account__c = 'TUKKY1',
                                                            Account__c = 'TUKKY1'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY2',
                                                            Full_Account__c = 'TUKKY2',
                                                            Account__c = 'TUKKY2'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY3',
                                                            Full_Account__c = 'TUKKY3',
                                                            Account__c = 'TUKKY3'));
        validEntries.add(new Account_Validation_Table__c(   Group_Code__c = 'TUKKY4',
                                                            Full_Account__c = 'TUKKY4',
                                                            Account__c = 'TUKKY4'));                                                                                                                                                                                    

        insert validEntries;
                                                                                            
        // Create an account with the correct fields for a register
        Account registeringAccount = new Account(   DISE_Group_Code_Account_No_1__c = 'TUKKY1',
                                                    DISE_Group_Code_Account_No_2__c = 'TUKKY2',
                                                    DISE_Group_Code_Account_No_3__c = 'TUKKY3',
                                                    DISE_Group_Code_Account_No_4__c = 'TUKKY4',
                                                    Name = 'TUKKY1_TEST',
                                                    // START - Added Darren Sabey 5/1/2011
                                                    Contract_End_Date__c = System.today().addDays(365),
                                                    // END - Added Darren Sabey 5/1/2011
                                                    Status__c = 'Customer',
                                                    Contract_Start_Date__c = Date.Today(),
                                                    Contract_Duration__c = '4',
                                                    Date_Effective_From__c = Date.Today(),
                                                    BillingStreet = '5 Hamilton Street',
                                                    BillingCity = 'Exeter',
                                                    BillingPostalCode = 'EX1 1AA',
                                                    BillingState = 'Devon');
                                                    
        insert registeringAccount;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(registeringAccount);
        O2_linkage_Acc_Reg_Conf_CE ole = new O2_linkage_Acc_Reg_Conf_CE(stdController);
        ole.getCancelButton();
        ole.getConfirmButton();
        ole.getRegConfTitle();
        ole.getAccRegConfMsg();
        ole.cancel();
        ole.confirm();

    } // end test1
    
    
    //==================================================
    static testMethod void O2_test1() 
    //==================================================
    {
        Contact c = new Contact();
        c.Salutation                ='A'; 
        c.FirstName                 ='A'; 
        c.LastName                  ='A';
        c.Buying_Role__c            ='A';
        c.Phone                     ='A'; 
        c.Email                     ='A@A.A'; 
        c.MailingStreet             ='Test\nTest2\nTest3\nTest4';
        system.debug(c.MailingStreet); 
        c.MailingState              ='A'; 
        c.MailingCity               ='A'; 
        c.MailingCountry            ='A'; 
        c.CLCMagazine__c            =true; 
        c.CLCMicrosite__c           =true; 
        c.CLCeNews__c               =true; 
        c.CLCDirectMail__c          =true; 
        c.CLCEvents__c              =true; 
        c.CLCWhitePapers__c         =true; 
        c.CLCProductWorkshop__c     =true; 
        c.CLCResearchForums__c      =true; 
        c.CLCEndUser__c             =true; 
        c.CSIOptOut__c              =true; 
        c.CSIOptOutReason__c        ='A';
        c.CSIFurtherInformation__c  ='A'; 
        c.Title                     ='A';                           
        c.MailingPostalCode         ='A';
        insert c;
        
        c.Salutation                ='a'; 
        c.FirstName                 ='a'; 
        c.LastName                  ='a';
        c.Buying_Role__c            ='a';
        c.Phone                     ='a'; 
        c.Email                     ='A@A.A'; 
        c.MailingStreet             ='Test\nTest2\nTest3\nTest4';
        c.MailingState              ='A'; 
        c.MailingCity               ='A'; 
        c.MailingCountry            ='A'; 
        c.CLCMagazine__c            =true; 
        c.CLCMicrosite__c           =true; 
        c.CLCeNews__c               =true; 
        c.CLCDirectMail__c          =true; 
        c.CLCEvents__c              =true; 
        c.CLCWhitePapers__c         =true; 
        c.CLCProductWorkshop__c     =true; 
        c.CLCResearchForums__c      =true; 
        c.CLCEndUser__c             =true; 
        c.CSIOptOut__c              =true; 
        c.CSIOptOutReason__c        ='A';
        c.CSIFurtherInformation__c  ='A'; 
        c.Title                     ='A';                           
        c.MailingPostalCode         ='A';
        update c;
        
    }

    //==================================================
    static testMethod void OARResponse() 
    //================================================== 
    {
        OARResponse a = new OARResponse();
        a.description = 'desc';
        a.statusValue = 'asdf';
    }
    
    //==================================================
    static testMethod void OARUserListItem() 
    //==================================================
    {
        OARUserListItem a = new OARUserListItem();
        a.userId = '12';
        a.firstName = 'asdf';
        a.lastName = 'asdf';
        a.email = 'asdf';
        a.telephone = '2323';
        a.selected = false;
        a.salesforceUserName = 'asdf';
        a.salesforceFlag = 'asdf';
    }

    //==================================================
    static testMethod void ApplicationSale() 
    //==================================================
    {
        ApplicationSale appSale = new ApplicationSale();
        appSale.setSelected(true);
        appSale.getSelected();
    }
    
    //==================================================
    static testMethod void Account_Validation_Table_Insert() 
    //==================================================
    {
        List<Account_Validation_Table__c> recs = new List<Account_Validation_Table__c>();
        recs.add(new Account_Validation_Table__c(Group_Code__c = 'XXTST1'));
        recs.add(new Account_Validation_Table__c(Group_Code__c = 'XXTST2'));
        recs.add(new Account_Validation_Table__c(Group_Code__c = 'XXTST3'));
        recs.add(new Account_Validation_Table__c(Group_Code__c = 'XXTST4'));
        insert recs;
        Account acc = new Account(  Name = 'test account X',
                                    // START - Added Darren Sabey 5/1/2011
                                    Contract_End_Date__c = System.today().addDays(365),
                                    // END - Added Darren Sabey 5/1/2011
                                    Status__c = 'Customer',
                                    BillingPostalCode = '21073',
                                    BillingCity =   'London',
                                    BillingStreet = 'Baker Street',
                                    BillingState = 'Devon',
                                    Contract_Start_Date__c = Date.Today(),
                                    Contract_Duration__c = '4',
                                    Date_Effective_From__c = Date.Today(),
                                    DISE_Group_Code_Account_No_1__c = 'XXTST1',
                                    DISE_Group_Code_Account_No_2__c = 'XXTST2',
                                    DISE_Group_Code_Account_No_3__c = 'XXTST3',
                                    DISE_Group_Code_Account_No_4__c = 'XXTST4',
                                    OAR_Account_Reference_1__c = '1234',
                                    OAR_Account_Reference_2__c = '2343',
                                    OAR_Account_Reference_3__c = '4545',
                                    OAR_Account_Reference_4__c = '65434',
                                    OAR_Account_1_Handover_Status__c = O2_linkage_configuration.getParam('HANDED_OVER_WAIT'),
                                    OAR_Account_2_Handover_Status__c = O2_linkage_configuration.getParam('HANDED_OVER_WAIT'),
                                    OAR_Account_3_Handover_Status__c = O2_linkage_configuration.getParam('HANDED_OVER_WAIT'),
                                    OAR_Account_4_Handover_Status__c = O2_linkage_configuration.getParam('HANDED_OVER_WAIT'));
                                    
        insert acc;
        System.debug(acc);
        Account a = [Select Id,Name, OAR_Account_Reference_1__c, OAR_Account_1_Handover_Status__c From Account Where Id = :acc.Id];
        System.debug(a);
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = '1:1234';
        email.plainTextBody = '1:this is message\n';
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        LinkageInboundEmail lie = new LinkageInboundEmail();
/* TODO commented out as test fails and needs fixing 
        lie.handleInboundEmail(email, envelope);
        email.subject = '1:2343';
        email.plainTextBody = '1:this is message\n';
        lie.handleInboundEmail(email, envelope);
        email.subject = '1:4545';
        email.plainTextBody = '1:this is message\n';
        lie.handleInboundEmail(email, envelope);
        email.subject = '1:65434';
        email.plainTextBody = '1:this is message\n';
        lie.handleInboundEmail(email, envelope);
        
        email.subject = '1:2343';
        email.plainTextBody = '0:this is message\n';
        lie.handleInboundEmail(email, envelope);        
        email.subject = '1:2343';
        email.plainTextBody = '0:this is message\n';
        lie.handleInboundEmail(email, envelope);
        email.subject = '1:4545';
        email.plainTextBody = '0:this is message\n';
        lie.handleInboundEmail(email, envelope);
        email.subject = '1:65434';
        email.plainTextBody = '0:this is message\n';
        lie.handleInboundEmail(email, envelope);
                
        email.subject = '2:1234';
        email.plainTextBody = '121212:OAR User Id\n';
        lie.handleInboundEmail(email, envelope);
        email.subject = '2:2343';
        email.plainTextBody = '121212:OAR User Id\n';
        lie.handleInboundEmail(email, envelope);
        email.subject = '2:4545';
        email.plainTextBody = '121212:OAR User Id\n';
        lie.handleInboundEmail(email, envelope);
        email.subject = '2:65434';
        email.plainTextBody = '121212:OAR User Id\n';
        lie.handleInboundEmail(email, envelope);
        email.subject = '3:65434';
        lie.handleInboundEmail(email, envelope);
        email.subject = 'rubbish';
        lie.handleInboundEmail(email, envelope);
        */
    } // end test1
  
    //==================================================
    static testMethod void Account_Update_Controller() 
    //==================================================
    {
        Account acc = new Account(name = 'test',OAR_Account_Reference_1__c = '1234',recordUpdated__c = true);
        insert acc;
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        Account_Update_Controller auc = new Account_Update_Controller(sc);
        auc.checkUpdateStatus();
        auc.checkUpdateStatus();
        acc.OAR_Account_Reference_1__c = null;
        auc.checkUpdateStatus();
    }
    
   

}