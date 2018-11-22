@isTest
public with sharing class fflib_QualifiedMethodAndArgValuesTest
{
	@isTest
	private static void getQualifiedMethodTest()
	{
		//Given
		fflib_QualifiedMethod qm1 = new fflib_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class } );
		fflib_QualifiedMethod qm2 = new fflib_QualifiedMethod('Type1', 'Method1', new List<Type>{ Integer.class } );
		fflib_QualifiedMethod qm3 = new fflib_QualifiedMethod('Type1', 'Method1', new List<Type>{ String.class } );
		fflib_QualifiedMethod qm4 = new fflib_QualifiedMethod('Type2', 'Method2', new List<Type>{ Integer.class, String.class, fflib_QualifiedMethodTest.class } );
		fflib_QualifiedMethod qm5 = new fflib_QualifiedMethod('', '', new List<Type>{} );
		fflib_QualifiedMethod qm6 = new fflib_QualifiedMethod(null, null, null );

		fflib_MethodArgValues av1 = new fflib_MethodArgValues(new List<Object>{ 'hello' });
		fflib_MethodArgValues av2 = new fflib_MethodArgValues(new List<Object>{ 'hello' });
		fflib_MethodArgValues av3 = new fflib_MethodArgValues(new List<Object>{ 'hi' });
		fflib_MethodArgValues av4 = new fflib_MethodArgValues(new List<Object>{ 'hello', 'hello', 'hello' });
		fflib_MethodArgValues av5 = new fflib_MethodArgValues(new List<Object>());
		fflib_MethodArgValues av6 = new fflib_MethodArgValues(null);

		fflib_QualifiedMethodAndArgValues qmav1 = new fflib_QualifiedMethodAndArgValues(qm1, av1, null);
		fflib_QualifiedMethodAndArgValues qmav2 = new fflib_QualifiedMethodAndArgValues(qm2, av2, null);
		fflib_QualifiedMethodAndArgValues qmav3 = new fflib_QualifiedMethodAndArgValues(qm3, av3, null);
		fflib_QualifiedMethodAndArgValues qmav4 = new fflib_QualifiedMethodAndArgValues(qm4, av4, null);
		fflib_QualifiedMethodAndArgValues qmav5 = new fflib_QualifiedMethodAndArgValues(qm5, av5, null);
		fflib_QualifiedMethodAndArgValues qmav6 = new fflib_QualifiedMethodAndArgValues(qm6, av6, null);

		qmav1.getQualifiedMethod();
		qmav1.getMethodArgValues();
		qmav1.getMockInstance();
		qmav1.toString();

		//When/thens
		System.assertEquals(qm1, qm1);
		System.assertEquals(qm1, qm2);
		System.assertNotEquals(qm1, qm3);
		System.assertNotEquals(qm1, qm4);
		System.assertNotEquals(qm1, qm5);
		System.assertNotEquals(qm1, qm6);

		System.assertEquals(qm2, qm2);
		System.assertNotEquals(qm2, qm3);
		System.assertNotEquals(qm2, qm4);
		System.assertNotEquals(qm2, qm5);
		System.assertNotEquals(qm2, qm6);

		System.assertEquals(qm3, qm3);
		System.assertNotEquals(qm3, qm4);
		System.assertNotEquals(qm3, qm5);
		System.assertNotEquals(qm3, qm6);

		System.assertEquals(qm4, qm4);
		System.assertNotEquals(qm4, qm5);
		System.assertNotEquals(qm4, qm6);

		System.assertEquals(qm5, qm5);
		System.assertNotEquals(qm5, qm6);

		System.assertEquals(qm6, qm6);
	}
}