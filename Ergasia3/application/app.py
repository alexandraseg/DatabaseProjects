# ----- CONFIGURE YOUR EDITOR TO USE 4 SPACES PER TAB ----- #
import pymysql as db #vivliothiki me sunartiseis ths mysql
import settings #kanei import to settings.py
import sys #vivliothiki sistimatos

def connection(): #to db pseudonumo gia to pymysql, xrisimopoiei th sunartisi connect, dinei ws parametrous to host, user, psw, schema
    ''' User this function to create your connections '''
    con = db.connect(
        settings.mysql_host, #I mtvl pou periexei to onoma tou ipologisti ston opoio trexei i vasi
        settings.mysql_user,  #to username ths mysql
        settings.mysql_passwd, #to psw pou antistoixei sto usn
        settings.mysql_schema) #to onoma tou sxhmatos pou 8eloume na xrhsimopoihsoume, sto paradeigma mas to movies
    return con #ena antikeimeno pou parexei th SINDESIMOTITA sth vash

def updateRank(rank1, rank2, movieTitle): #h synartisi auti kanei update to rank ths tainias
    #h timh ths metavlitis rank1 proerxetai apo th forma

    # Create a new connection
    con=connection() #kalei th synarthsh ths grammhs 6
    
    # Create a cursor on the connection
    cur=con.cursor() #kalei th synarthsh cursor apo to antikeimeno con kai apothikeuei to apotelesma sth mtvl cur



    try:
        rank1=float(rank1)
    except ValueError:
        return [("status",),("error",),] #epistrefei lista ths opoias to prwto stoixeio einai tuple tou opoiou to prwto stoixeio einai string
    try:
        rank2=float(rank2)
    except ValueError:
        return [("status",),("error",),]

    if rank1<0 or rank1>10 or rank2<0 or rank2>10: #elegxos arithmitikwn timwn ektos oriwn
        print("@Error:ektos oriwn")
        return [("status",),("error",),]
    query="select m.rank from movie m where m.title='%s';"%(movieTitle) #ftiaxnoume to string tou query dinontas to onoma ths tainias
    num_results=cur.execute(query) 
    #sth mtv num_results kaloume th sunarthsh execute apo to antikeimeno cur (grammh 22) dinontas ws parametro th mtv query (grammi 38)
    #h execute ektelei to query sth mysql kai epistrefei ton arithmo twn seirwn tou apotelesmatos
    print("***")
    print(num_results)
    print("*** RES PRINT ***")

    if num_results>1: #elegxoume an uparxoun perissoteres ths mias tainies me to idio onoma
        print("@Error:number of results>1")
        return [("status",),("error",),]

    if num_results==0: #elegxoume an den uparxei tainia me auto to onoma
        print("@Error: number of results = 0")
        return [("status",),("error",),]
    res=cur.fetchone() 
    #sth mtv RES kaloume th sunartisi fetchone() apo to antikeimeno cur, 
    #me thn opoia pairnoume th prwth grammh tou apotelesmatos tou query
    #to fetchone einai tuple like
    print(res)
    movieRank=res[0] #to fetchone einai tuple like
    if movieRank is None:
        newRank=(rank1+rank2)/2.0
    else:
        newRank=(rank1+rank2+movieRank)/3.0
    updateQuery="update movie set rank=%f where title='%s';"%(newRank,movieTitle)
    cur.execute(updateQuery)
    con.commit()
    print(updateQuery)
    return [("status",),("ok",),]

def colleaguesOfColleagues(actorId1, actorId2):

    # Create a new connection()
    con=connection()
    
    # Create a cursor on the connection
    cur=con.cursor()
    
    print (actorId1, actorId2)
    
    return [("movieTitle", "colleagueOfActor1", "colleagueOfActor2", "actor1","actor2",),]

def actorPairs(actorId):

    # Create a new connection
    con=connection()
    
    # Create a cursor on the connection
    cur=con.cursor()
	
	
    print (actorId)
    
    return [("actor2Id",),]
	
def selectTopNactors(n):

    # Create a new connection
    con=connection()
    
    # Create a cursor on the connection
    cur=con.cursor()

    query="select genre_id from genre;" # 
    num_results=cur.execute(query) #ekteloume to query kai sth metavliti num_results apo8hkeuetai o arithmos twn grammwn
    res=cur.fetchall() #sth mtvl res apothikeuetai h lista me ta apotelesmata
    genres=[] #dhmiourgw mia adeia lista
    for element in res: #sthn lista genres pros8etw to prwto stoixeio (dhladh to genre) ka8e tupple ths listas res 
        genres.append(element[0])
    print(genres)
    resultList=[] #dhmiourgw mia adeia lista
    for genre in genres: #ektelw to akolou8o query gia ka8e genre
        query="""SELECT 
                a.actor_id, COUNT(DISTINCT m.movie_id) AS plithos_tainiwn, g.genre_name
            FROM
                actor a,
                role r,
                movie m,
                movie_has_genre mhg,
                genre g
            WHERE
                a.actor_id = r.actor_id
                    AND r.movie_id = m.movie_id
                    AND m.movie_id = mhg.movie_id
                    AND g.genre_id = mhg.genre_id
                    AND g.genre_id=%d
            GROUP BY a.actor_id
            ORDER BY plithos_tainiwn DESC
            LIMIT %d;"""%(int(genre),int(n))
        print(query)
        num_results=cur.execute(query)
        res=cur.fetchall()
        for result in res: #gia ka8e apotelesma dhmiourgw ena tupple me thn epi8umiti seira twn mtvtwn, to opoio pros8etw sth lista resultList
            t=(result[2], result[0] , result[1] )
            resultList.append(t)




    head=[("genreName", "actorId", "numberOfMovies")] #dhmiourgw mia lista me tous titlous twn apotelesmatwn
    head.extend(resultList) #epekteinw th lista me ta apotelesmata
    return head #epistrefw th lista

