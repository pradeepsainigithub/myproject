public class RandomContactFactory {
    public static List<contact> generateRandomContacts(Integer ilimit, string slastname) {
        List<contact> conList = new List<contact>();
        for(Integer i =0;i<ilimit; i++) {
            contact con = new contact(firstName = 'Test '+i,lastname =slastname);
            conList.add(con);
        }
        return conList;
    }
}